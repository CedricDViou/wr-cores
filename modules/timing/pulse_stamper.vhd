-------------------------------------------------------------------------------
-- Entity: pulse_stamper
-- File: pulse_stamper.vhd
-- Description: a time-tagger which associates a time-tag with an asyncrhonous
-- input pulse.
-- Author: Javier Serrano (Javier.Serrano@cern.ch)
-- Date: 24 January 2012
-- Version: 0.01
-- Todo: Factor out syncrhonizer in a separate reusable block.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- Copyright (c) 2012 CERN
--
-- Copyright and related rights are licensed under the Solderpad Hardware
-- License, Version 0.51 (the “License”) (which enables you, at your option,
-- to treat this file as licensed under the Apache License 2.0); you may not
-- use this file except in compliance with the License. You may obtain a copy
-- of the License at http://solderpad.org/licenses/SHL-0.51.
-- Unless required by applicable law or agreed to in writing, software,
-- hardware and materials distributed under this License is distributed on an
-- “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
-- or implied. See the License for the specific language governing permissions
-- and limitations under the License.
--
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;

entity pulse_stamper is
  
  generic (
    -- reference clock frequency
    g_ref_clk_rate : integer := 125000000);

  port(
    clk_ref_i : in std_logic;           -- timing reference clock
    clk_sys_i : in std_logic;           -- data output reference clock
    rst_n_i   : in std_logic;           -- system reset

    pulse_a_i : in std_logic;           -- pulses to be stamped

    -------------------------------------------------------------------------------
    -- Timing input (from WRPC), clk_ref_i domain
    ------------------------------------------------------------------------------

    -- 1: time given on tm_utc_i and tm_cycles_i is valid (otherwise, don't timestamp)
    tm_time_valid_i : in std_logic;
    -- number of seconds
    tm_tai_i        : in std_logic_vector(39 downto 0);
    -- number of clk_ref_i cycles
    tm_cycles_i     : in std_logic_vector(27 downto 0);


    ---------------------------------------------------------------------------
    -- Time tag output (clk_sys_i domain)
    ---------------------------------------------------------------------------
    tag_tai_o      : out std_logic_vector(39 downto 0);
    tag_cycles_o   : out std_logic_vector(27 downto 0);
    -- single-cycle pulse: strobe tag on tag_utc_o and tag_cycles_o
    tag_valid_o : out std_logic
    );

  
end pulse_stamper;

architecture rtl of pulse_stamper is

 -- Signals for input anti-metastability ffs
 signal pulse_ref : std_logic_vector(2 downto 0);
 signal pulse_ref_p1 : std_logic;
 signal pulse_ref_p1_d1 : std_logic;
 
 -- Time tagger signals
 signal tag_utc_ref : std_logic_vector(39 downto 0);
 signal tag_cycles_ref : std_logic_vector(27 downto 0);

 -- Signals for synchronizer
 signal rst_from_sync : std_logic;
 signal pulse_ref_d2 : std_logic;
 signal pulse_sys : std_logic_vector(2 downto 0);
 signal pulse_sys_p1 : std_logic;
 signal pulse_back : std_logic_vector(2 downto 0);
 
begin  -- architecture rtl

 -- Synchronization of external pulse into the clk_ref_i clock domain
 sync_ext_pulse: process (clk_ref_i)
 begin
  if clk_ref_i'event and clk_ref_i='1' then
    pulse_ref <= pulse_ref(1 downto 0) & pulse_a_i;
    pulse_ref_p1 <= pulse_ref(1) and not pulse_ref(2);
    pulse_ref_p1_d1 <= pulse_ref_p1 and tm_time_valid_i;
  end if;
 end process sync_ext_pulse;

 -- Time tagging of the pulse, still in the clk_ref_i domain
 tagger: process (clk_ref_i)
 begin
  if clk_ref_i'event and clk_ref_i='1' then
    if pulse_ref_p1='1' and tm_time_valid_i='1' then
      tag_utc_ref <= tm_tai_i;
      tag_cycles_ref <= tm_cycles_i;
    end if;
  end if;
 end process tagger;

 -- Synchronizer to pass UTC register data to the system clock domain
 -- This synchronizer is made with the following three processes

 -- First one FF with async reset, still in the clk_ref_i domain
 sync_first_ff: process (clk_ref_i, rst_n_i, rst_from_sync)
 begin
  if rst_n_i='0' or rst_from_sync='1' then
    pulse_ref_d2 <= '0';
  elsif clk_ref_i'event and clk_ref_i='1' then
    if pulse_ref_p1_d1='1' then
      pulse_ref_d2 <= '1';
    end if;
  end if;
 end process sync_first_ff;

 -- Then three FFs to take the strobe safely into the clk_sys_i domain
 sync_sys: process (clk_sys_i)
 begin
  if clk_sys_i'event and clk_sys_i='1' then
   pulse_sys <= pulse_sys(1 downto 0) & pulse_ref_d2;
   pulse_sys_p1 <= pulse_sys(1) and not pulse_sys(2);
  end if;
 end process sync_sys;

 -- And then back into the clk_ref_i domain
 sync_ref: process (clk_ref_i)
 begin
  if clk_ref_i'event and clk_ref_i='1' then
    pulse_back <= pulse_back(1 downto 0) & pulse_sys(2);
    rst_from_sync <= pulse_back(2);
  end if;
 end process sync_ref;

 -- Now we can take the time tags into the clk_sys_i domain
 sys_tags: process (clk_sys_i)
 begin
  if clk_sys_i'event and clk_sys_i='1' then
    if rst_n_i='0' then
     tag_tai_o <= (others=>'0');
     tag_cycles_o <= (others=>'0');
     tag_valid_o <= '0';
    elsif pulse_sys_p1='1' then
     tag_tai_o <= tag_utc_ref;
     tag_cycles_o <= tag_cycles_ref;
     tag_valid_o <= '1';
    else
     tag_valid_o <='0';
    end if;
  end if;
 end process sys_tags;
 
end architecture rtl;

library ieee;
use ieee.std_logic_1164.all;

package wr_pll_ctrl_pkg is
  
  type t_data_array is array(natural range<>) of std_logic_vector(7 downto 0);
  type t_addr_array is array(natural range<>) of std_logic_vector(15 downto 0);

  constant c_spi_addr_array : t_addr_array :=(
    x"0000",x"0001",x"0002",x"0003",x"0004",x"0010",x"0011",x"0012",x"0013",x"0014",x"0015",x"0016",x"0017",x"0018",x"0019",x"001A",
    x"001B",x"001C",x"001D",x"001E",x"001F",x"00A0",x"00A1",x"00A2",x"00A3",x"00A4",x"00A5",x"00A6",x"00A7",x"00A8",x"00A9",x"00AA",
    x"00AB",x"00F0",x"00F1",x"00F2",x"00F3",x"00F4",x"00F5",x"0140",x"0141",x"0142",x"0143",x"0190",x"0191",x"0192",x"0193",x"0194",
    x"0195",x"0196",x"0197",x"0198",x"0199",x"019A",x"019B",x"019C",x"019D",x"019E",x"019F",x"01A0",x"01A1",x"01A2",x"01A3",x"01E0",
    x"01E1",x"0230",x"0231",x"0232"
  );

  constant c_spi_data_array_normal : t_data_array :=(
    x"99"  ,x"00"  ,x"10"  ,x"C3"  ,x"00"  ,x"7C"  ,x"05"  ,x"00"  ,x"0C"  ,x"12"  ,x"00"  ,x"05"  ,x"88"  ,x"07"  ,x"00"  ,x"00",
    x"00"  ,x"02"  ,x"00"  ,x"00"  ,x"0E"  ,x"01"  ,x"00"  ,x"00"  ,x"01"  ,x"00"  ,x"00"  ,x"01"  ,x"00"  ,x"00"  ,x"01"  ,x"00",
    x"00"  ,x"0A"  ,x"0A"  ,x"08"  ,x"08"  ,x"0A"  ,x"0A"  ,x"42"  ,x"42"  ,x"42"  ,x"42"  ,x"00"  ,x"08"  ,x"00"  ,x"00"  ,x"80",
    x"00"  ,x"00"  ,x"80"  ,x"00"  ,x"11"  ,x"00"  ,x"00"  ,x"20"  ,x"00"  ,x"00"  ,x"00"  ,x"00"  ,x"20"  ,x"00"  ,x"00"  ,x"01",
    x"02"  ,x"00"  ,x"00"  ,x"01"
  );

end wr_pll_ctrl_pkg;

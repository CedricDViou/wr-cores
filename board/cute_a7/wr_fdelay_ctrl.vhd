library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wr_fdelay_ctrl is
generic (
    fdelay_ch0 : std_logic_vector(8 downto 0) := (others=>'0');
    fdelay_ch1 : std_logic_vector(8 downto 0) := (others=>'0'));
port (
    rst_sys_n_i      : in  std_logic;
    clk_sys_i        : in  std_logic;

    delay_en_o       : out std_logic;
    delay_sload_o    : out std_logic;
    delay_sdin_o     : out std_logic;
    delay_sclk_o     : out std_logic
    );
end wr_fdelay_ctrl;

architecture struct of wr_fdelay_ctrl is
  
  constant c_fdelay_ch0 : std_logic_vector(8 downto 0) :="000001010";
  constant c_fdelay_ch1 : std_logic_vector(8 downto 0) :=(others=>'0');

  type fdly_ctrl_state is (S_IDLE, S_START_CONF_CH0, S_CONFIG_CH0, S_SPI_TRANS_CHO, S_CONFIG_DONE_CH0, S_FINISH_CH0, S_START_CONF_CH1, S_CONFIG_CH1, S_SPI_TRANS_CH1, S_CONFIG_DONE_CH1, S_FINISH_CH1);
  
  signal delay_en     :std_logic;      
  signal delay_sload  :std_logic;    
  signal delay_sdin   :std_logic;     
  signal delay_sclk   :std_logic;     

  signal spi_data    : std_logic_vector(10 downto 0):=(others=>'0');

begin    
  
  P_FINE_DELAY_SPI: process(clk_sys_i)
    variable state  : fdly_ctrl_state := S_IDLE;
    variable spi_cnt: natural range 0 to 12;
  begin
    if rising_edge(clk_sys_i) then
      if (rst_sys_n_i='0') then
        spi_data      <= (others=>'0');
        delay_en      <= '0';
        delay_sload   <= '0';
        delay_sdin    <= '0';
        delay_sclk    <= '0';
        spi_cnt       := 0;
        state         := S_IDLE;
      else 
        case(state) is
          when S_IDLE => 
            spi_data     <= (others=>'0');
            delay_en     <= '0';
            delay_sload  <= '0';
            delay_sdin   <= '0';
            delay_sclk   <= '0';
            spi_cnt      := 0;
            state        := S_START_CONF_CH0;
  
          when S_START_CONF_CH0 =>
            delay_en  <= '1';
            spi_data  <= c_fdelay_ch0 & '0' & '0'; 
            state     := S_CONFIG_CH0;

          when S_CONFIG_CH0 =>
            delay_sdin <= spi_data(0);
            delay_sclk <= '0';
            state      := S_SPI_TRANS_CHO;
            if(spi_cnt = 11) then
              delay_sload <= '1';
              state       := S_CONFIG_DONE_CH0;
            end if;
          
          when S_SPI_TRANS_CHO =>
            spi_data   <= '0' & spi_data(10 downto 1);
            delay_sclk <= '1';
            spi_cnt    := spi_cnt + 1;
            state      := S_CONFIG_CH0;

          when S_CONFIG_DONE_CH0 =>
            delay_sload <= '0';
            spi_data    <= fdelay_ch1 & '0' & '1'; 
            spi_cnt     := 0;
            state       := S_FINISH_CH0;

          when S_FINISH_CH0 =>
            delay_en    <= '0';
            state       :=  S_START_CONF_CH1;

          when S_START_CONF_CH1 =>
            delay_en  <= '1';
            spi_data  <= c_fdelay_ch1 & '0' & '1'; 
            state     := S_CONFIG_CH1;

          when S_CONFIG_CH1 =>
            delay_sdin <= spi_data(0);
            delay_sclk <= '0';
            state      := S_SPI_TRANS_CH1;
            if(spi_cnt = 11) then
              delay_sload <= '1';
              state       := S_CONFIG_DONE_CH1;
            end if;
          
          when S_SPI_TRANS_CH1 =>
            spi_data   <= '0' & spi_data(10 downto 1);
            delay_sclk <= '1';
            spi_cnt    := spi_cnt + 1;
            state      := S_CONFIG_CH1;

          when S_CONFIG_DONE_CH1 =>
            delay_sload <= '0';
            spi_data    <= (others => '0'); 
            spi_cnt     := 0;
            state       := S_FINISH_CH1;

          when S_FINISH_CH1 =>
            delay_en  <= '0';
            state     := S_FINISH_CH1;

          when others =>
            state := S_IDLE;

        end case;
      end if;
    end if;
  end process P_FINE_DELAY_SPI;

  delay_en_o    <= delay_en;        
  delay_sload_o <= delay_sload;      
  delay_sdin_o  <= delay_sdin;       
  delay_sclk_o  <= delay_sclk;   

end struct;


-- @brief Data types for working with AXI4 interfaces
-- @details Based on the document "ARM IHI 0022E (ID022613): AMBA AXI and ACE Protocol Specification"
-- Available here (after login): http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.ihi0022e/index.html

library ieee;
use ieee.std_logic_1164.all;


package axi_pkg is

  ------------------------------------------------------------------------------
  -- A (Address Read and Address Write) channels
  ------------------------------------------------------------------------------

  constant axi_a_addr_sz : integer := 32; -- @TODO what?
  constant axi_a_len_sz : integer := 8; -- Number of transfers = len + 1
  constant axi_a_size_sz : integer := 3; -- Bytes per transfer = 2^size

  constant axi_a_burst_sz : integer := 2;
  constant axi_a_burst_fixed : std_logic_vector(axi_a_burst_sz - 1 downto 0) := "00";
  constant axi_a_burst_incr : std_logic_vector(axi_a_burst_sz - 1 downto 0) := "01";
  constant axi_a_burst_wrap : std_logic_vector(axi_a_burst_sz - 1 downto 0) := "10";

  constant axi_a_lock_sz : integer := 1; -- @note Two bytes in AXI3, with additional mode "Locked access"
  constant axi_a_lock_normal : std_logic_vector(axi_a_lock_sz - 1 downto 0) := "0";
  constant axi_a_lock_exclusive : std_logic_vector(axi_a_lock_sz - 1 downto 0) := "1";

  constant axi_a_cache_sz : integer := 4;
  constant axi_a_cache_device_non_bufferable : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "0000";
  constant axi_a_cache_device_bufferable : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "0001";
  constant axi_a_cache_normal_non_cacheable_non_bufferable : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "0010";
  constant axi_a_cache_normal_non_cacheable_bufferable : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "0011";
  constant axi_ar_cache_write_through_no_allocate : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "1010";
  constant axi_aw_cache_write_through_no_allocate : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "0110";
  constant axi_a_cache_write_through_read_allocate : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "0110";
  constant axi_a_cache_write_through_write_allocate : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "1010";
  constant axi_a_cache_write_through_read_and_write_allocate : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "1110";
  constant axi_ar_cache_write_back_no_allocate : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "1011";
  constant axi_aw_cache_write_back_no_allocate : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "0111";
  constant axi_a_cache_write_back_read_allocate : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "0111";
  constant axi_a_cache_write_back_write_allocate : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "1011";
  constant axi_a_cache_write_back_read_and_write_allocate : std_logic_vector(axi_a_cache_sz - 1 downto 0) := "1111";

  constant axi_a_prot_sz : integer := 3;
  constant axi_a_prot_privileged : std_logic_vector(axi_a_prot_sz - 1 downto 0) := "001";
  constant axi_a_prot_unprivileged : std_logic_vector(axi_a_prot_sz - 1 downto 0) := "000";
  constant axi_a_prot_secure : std_logic_vector(axi_a_prot_sz - 1 downto 0) := "000";
  constant axi_a_prot_nonsecure : std_logic_vector(axi_a_prot_sz - 1 downto 0) := "010";
  constant axi_a_prot_data : std_logic_vector(axi_a_prot_sz - 1 downto 0) := "000";
  constant axi_a_prot_instruction : std_logic_vector(axi_a_prot_sz - 1 downto 0) := "100";

  constant axi_a_region_sz : integer := 4;

  type axi_m2s_a_t is record
    valid : std_logic;
    addr : std_logic_vector(axi_a_addr_sz - 1 downto 0);
    len : std_logic_vector(axi_a_len_sz - 1 downto 0);
    size : std_logic_vector(axi_a_size_sz - 1 downto 0);
    burst : std_logic_vector(axi_a_burst_sz - 1 downto 0);
    -- @note Excluded members: id, lock, cache, prot, region.
    -- These are typically not changed on a transfer-to-transfer basis.
  end record;

  constant axi_m2s_a_init : axi_m2s_a_t := (valid => '0', others => (others => '0'));
  constant axi_m2s_a_sz : integer := axi_a_addr_sz + axi_a_len_sz + axi_a_size_sz + axi_a_burst_sz; -- Exluded member: valid

  function to_slv(data : axi_m2s_a_t) return std_logic_vector;
  function to_axi_m2s_a(data : std_logic_vector) return axi_m2s_a_t;

  type axi_s2m_a_t is record
    ready : std_logic;
  end record;

  constant axi_s2m_a_init : axi_s2m_a_t := (ready => '0');


  ------------------------------------------------------------------------------
  -- W (Write Data) channels
  ------------------------------------------------------------------------------

  constant axi_data_max_sz : integer := 128; -- Max value
  constant axi_w_strb_max_sz : integer := axi_data_max_sz / 8; -- Max value

  type axi_m2s_w_t is record
    valid : std_logic;
    data : std_logic_vector(axi_data_max_sz - 1 downto 0);
    strb : std_logic_vector(axi_w_strb_max_sz - 1 downto 0);
    last : std_logic;
    -- @note AXI3 has an id as well
  end record;

  constant axi_m2s_w_init : axi_m2s_w_t := (valid => '0', data => (others => '-'), last => '0', others => (others => '0'));

  function axi_w_strb_sz(data_width : integer)  return integer;
  function axi_m2s_w_sz(data_width : integer)  return integer;
  function to_slv(data : axi_m2s_w_t; data_width : integer) return std_logic_vector;
  function to_axi_m2s_w(data : std_logic_vector; data_width : integer) return axi_m2s_w_t;

  type axi_s2m_w_t is record
    ready : std_logic;
  end record;

  constant axi_s2m_w_init : axi_s2m_w_t := (ready => '0');


  ------------------------------------------------------------------------------
  -- B (Write Response) channels
  ------------------------------------------------------------------------------

  type axi_m2s_b_t is record
    ready : std_logic;
  end record;

  constant axi_m2s_b_init : axi_m2s_b_t := (ready => '0');

  constant axi_resp_sz : integer := 2;
  constant axi_resp_okay : std_logic_vector(axi_resp_sz - 1 downto 0) := "00";
  constant axi_resp_exokay : std_logic_vector(axi_resp_sz - 1 downto 0) := "01"; -- Exclusive access okay.
  constant axi_resp_slverr : std_logic_vector(axi_resp_sz - 1 downto 0) := "10"; -- Slave error. Slave wishes to return error.
  constant axi_resp_decerr : std_logic_vector(axi_resp_sz - 1 downto 0) := "11"; -- Decode error. There is no slave at transaction address.

  type axi_s2m_b_t is record
    valid : std_logic;
    resp : std_logic_vector(axi_resp_sz - 1 downto 0);
  end record;

  constant axi_s2m_b_init : axi_s2m_b_t := (valid => '0', others => (others => '0'));


  ------------------------------------------------------------------------------
  -- R (Read Data) channels
  ------------------------------------------------------------------------------

  type axi_m2s_r_t is record
    ready : std_logic;
  end record;

  constant axi_m2s_r_init : axi_m2s_r_t := (ready => '0');

  type axi_s2m_r_t is record
    valid : std_logic;
    data : std_logic_vector(axi_data_max_sz - 1 downto 0);
    resp : std_logic_vector(axi_resp_sz - 1 downto 0);
    last : std_logic;
    -- @note Excluded member id
  end record;

  constant axi_s2m_r_init : axi_s2m_r_t := (valid => '0', last => '0', others => (others => '0'));
  function axi_s2m_r_sz(data_width : integer)  return integer;
  function to_slv(data : axi_s2m_r_t; data_width : integer) return std_logic_vector;
  function to_axi_s2m_r(data : std_logic_vector; data_width : integer) return axi_s2m_r_t;


  ------------------------------------------------------------------------------
  -- The complete buses
  ------------------------------------------------------------------------------

  type axi_read_m2s_t is record
    ar : axi_m2s_a_t;
    r : axi_m2s_r_t;
  end record;

  constant axi_read_m2s_init : axi_read_m2s_t := (ar => axi_m2s_a_init, r => axi_m2s_r_init);

  type axi_read_s2m_t is record
    ar : axi_s2m_a_t;
    r : axi_s2m_r_t;
  end record;

  constant axi_read_s2m_init : axi_read_s2m_t := (ar => axi_s2m_a_init, r => axi_s2m_r_init);

  type axi_write_m2s_t is record
    aw : axi_m2s_a_t;
    w : axi_m2s_w_t;
    b : axi_m2s_b_t;
  end record;

  constant axi_write_m2s_init : axi_write_m2s_t := (aw => axi_m2s_a_init, w => axi_m2s_w_init, b => axi_m2s_b_init);

  type axi_write_s2m_t is record
    aw : axi_s2m_a_t;
    w : axi_s2m_w_t;
    b : axi_s2m_b_t;
  end record;

  constant axi_write_s2m_init : axi_write_s2m_t := (aw => axi_s2m_a_init, w => axi_s2m_w_init, b => axi_s2m_b_init);

end;

package body axi_pkg is

  function to_slv(data : axi_m2s_a_t) return std_logic_vector is
    variable result : std_logic_vector(axi_m2s_a_sz - 1 downto 0);
    variable lo, hi : integer := 0;
  begin
    lo := 0;
    hi := lo + data.addr'length - 1;
    result(hi downto lo) := data.addr;
    lo := hi + 1;
    hi := lo + data.len'length - 1;
    result(hi downto lo) := data.len;
    lo := hi + 1;
    hi := lo + data.size'length - 1;
    result(hi downto lo) := data.size;
    lo := hi + 1;
    hi := lo + data.burst'length - 1;
    result(hi downto lo) := data.burst;
    assert hi = result'high;
    return result;
  end function;

  function to_axi_m2s_a(data : std_logic_vector) return axi_m2s_a_t is
    variable result : axi_m2s_a_t;
    variable lo, hi : integer := 0;
  begin
    lo := 0;
    hi := lo + result.addr'length - 1;
    result.addr := data(hi downto lo);
    lo := hi + 1;
    hi := lo + result.len'length - 1;
    result.len := data(hi downto lo);
    lo := hi + 1;
    hi := lo + result.size'length - 1;
    result.size := data(hi downto lo);
    lo := hi + 1;
    hi := lo + result.burst'length - 1;
    result.burst := data(hi downto lo);
    assert hi = data'high;
    return result;
  end function;

  function axi_w_strb_sz(data_width : integer)  return integer is
  begin
    return data_width / 8;
  end function;

  function axi_m2s_w_sz(data_width : integer) return integer is
  begin
    return data_width + axi_w_strb_sz(data_width) + 1; -- Exluded member: valid
  end function;

  function to_slv(data : axi_m2s_w_t; data_width : integer) return std_logic_vector is
    constant result_sz : integer := axi_m2s_w_sz(data_width);
    variable result : std_logic_vector(result_sz - 1 downto 0);
    variable lo, hi : integer := 0;
  begin
    lo := 0;
    hi := lo + data_width - 1;
    result(hi downto lo) := data.data(data_width - 1 downto 0);
    lo := hi + 1;
    hi := lo + axi_w_strb_sz(data_width) - 1;
    result(hi downto lo) := data.strb(axi_w_strb_sz(data_width) - 1 downto 0);
    lo := hi + 1;
    hi := lo;
    result(hi) := data.last;
    assert hi = result'high;
    return result;
  end function;

  function to_axi_m2s_w(data : std_logic_vector; data_width : integer) return axi_m2s_w_t is
    variable result : axi_m2s_w_t;
    variable lo, hi : integer := 0;
  begin
    lo := 0;
    hi := lo + data_width - 1;
    result.data(data_width - 1 downto 0) := data(hi downto lo);
    lo := hi + 1;
    hi := lo + axi_w_strb_sz(data_width) - 1;
    result.strb(axi_w_strb_sz(data_width) - 1 downto 0) := data(hi downto lo);
    lo := hi + 1;
    hi := lo;
    result.last := data(hi);
    assert hi = data'high;
    return result;
  end function;

  function axi_s2m_r_sz(data_width : integer)  return integer is
  begin
    return data_width + axi_resp_sz + 1; -- Exluded member: valid
  end function;

  function to_slv(data : axi_s2m_r_t; data_width : integer) return std_logic_vector is
    constant result_sz : integer := axi_s2m_r_sz(data_width);
    variable result : std_logic_vector(result_sz - 1 downto 0);
    variable lo, hi : integer := 0;
  begin
    lo := 0;
    hi := lo + data_width - 1;
    result(hi downto lo) := data.data(data_width - 1 downto 0);
    lo := hi + 1;
    hi := lo + axi_resp_sz - 1;
    result(hi downto lo) := data.resp;
    lo := hi + 1;
    hi := lo;
    result(hi) := data.last;
    assert hi = result'high;
    return result;
  end function;

  function to_axi_s2m_r(data : std_logic_vector; data_width : integer) return axi_s2m_r_t is
    variable result : axi_s2m_r_t;
    variable lo, hi : integer := 0;
  begin
    lo := 0;
    hi := lo + data_width - 1;
    result.data(data_width - 1 downto 0) := data(hi downto lo);
    lo := hi + 1;
    hi := lo + axi_resp_sz - 1;
    result.resp := data(hi downto lo);
    lo := hi + 1;
    hi := lo;
    result.last := data(hi);
    assert hi = data'high;
    return result;
  end function;

end;

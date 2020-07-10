/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_AHB_ANALYZER_SV
`define YUU_AHB_ANALYZER_SV

class yuu_ahb_analyzer extends uvm_subscriber #(yuu_ahb_item);
  yuu_ahb_agent_config cfg;
  uvm_event_pool       events;

  protected time m_start_time;
  protected time m_end_time;
  protected bit  m_start = 0;
  protected int  m_count = 0;

  `uvm_component_utils_begin(yuu_ahb_analyzer)
  `uvm_component_utils_end

  extern                   function      new(string name, uvm_component parent);
  extern           virtual function void connect_phase(uvm_phase phase);
  extern           virtual task          run_phase(uvm_phase phase);
  extern           virtual function void report_phase(uvm_phase phase);

  extern           virtual function void write(yuu_ahb_item t);
  extern protected virtual task          measure_start();
  extern protected virtual task          measure_end();
endclass

function yuu_ahb_analyzer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction

function void yuu_ahb_analyzer::connect_phase(uvm_phase phase);
  this.events = cfg.events;
endfunction

task yuu_ahb_analyzer::run_phase(uvm_phase phase);
  measure_start();
  measure_end();
endtask

function void yuu_ahb_analyzer::report_phase(uvm_phase phase);
  real tput_rate;

  if (m_count == 0) begin
    `uvm_warning("report_phase", "Analyzer haven't received any transaction")
    return;
  end

  tput_rate = real'(m_count)/(m_end_time - m_start_time) * 1000;
  `uvm_info("report_phase", $sformatf("AHB %s speed is %f", cfg.agent_type, tput_rate), UVM_LOW);
endfunction


function void yuu_ahb_analyzer::write(yuu_ahb_item t);
  if (m_start)
    m_count += t.len + 1;
endfunction

task yuu_ahb_analyzer::measure_start();
  uvm_event e = events.get($sformatf("%s_analyzer_measure_begin", cfg.get_name()));

  e.wait_on();
  m_start_time = $realtime();
  m_start = 1;
  `uvm_info("measure_start", $sformatf("%s analyzer start measure @ %t", cfg.get_name(), m_start_time), UVM_LOW)
endtask

task yuu_ahb_analyzer::measure_end();
  uvm_event e = events.get($sformatf("%s_analyzer_measure_end", cfg.get_name()));

  e.wait_on();
  m_end_time = $realtime();
  m_start = 0;
  `uvm_info("measure_end", $sformatf("%s analyzer end measure @ %t", cfg.get_name(), m_end_time), UVM_LOW)
endtask

`endif
/////////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
// For more information, see LICENCE in the main folder
/////////////////////////////////////////////////////////////////////////////////////
`ifndef YUU_AHB_MASTER_COLLECTOR_SV
`define YUU_AHB_MASTER_COLLECTOR_SV

class yuu_ahb_master_collector extends uvm_subscriber #(yuu_ahb_item);
  virtual yuu_ahb_master_interface vif;

  yuu_ahb_master_config cfg;
  uvm_event_pool events;

  yuu_ahb_item item;

  covergroup ahb_transaction_cg();
    direction: coverpoint item.direction {
      bins ahb_write = {WRITE};
      bins ahb_read  = {READ};
    }
  endgroup

  `uvm_component_utils_begin(yuu_ahb_master_collector)
  `uvm_component_utils_end

  extern                   function      new              (string name, uvm_component parent);
  extern           virtual function void build_phase      (uvm_phase phase);
  extern           virtual task          main_phase       (uvm_phase phase);
  extern           virtual function void write            (yuu_ahb_item t);
endclass

function yuu_ahb_master_collector::new(string name, uvm_component parent);
  super.new(name, parent);

  ahb_transaction_cg = new;
endfunction

function void yuu_ahb_master_collector::build_phase(uvm_phase phase);
  if (cfg == null)
    `uvm_fatal("build_phase", "yuu_ahb_master agent configuration is null")
endfunction

task yuu_ahb_master_collector::main_phase(uvm_phase phase);
endtask

function void yuu_ahb_master_collector::write(yuu_ahb_item t);
  item = yuu_ahb_master_item::type_id::create("item");
  item.copy(t);
  ahb_transaction_cg.sample();
endfunction

`endif


package bsg_tag_ram_pkg;

  // TODO: Create/modify payload structure for each client. This struct allows
  // us to "label" bits recieved by the tag clients. Should have 1 struct per
  // client!
  
  //typedef struct packed {} payload_s;

  parameter bsg_tag_client_num_lp = SETME; // TODO: Set me to the number of tag clients used

  parameter bsg_tag_max_payload_width_lp = SETME; // TODO: Set me to the max width of all bsg_tag_clients 


  ///////////////////////////////
  // Do not touch me!
  //
  parameter bsg_tag_lg_max_payload_width_lp = `BSG_SAFE_CLOG2(bsg_tag_max_payload_width_lp + 1);

endpackage


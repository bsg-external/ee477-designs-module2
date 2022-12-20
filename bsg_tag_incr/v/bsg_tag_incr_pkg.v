
package bsg_tag_incr_pkg;

  // Create/modify payload structure for each client. This struct allows
  // us to "label" bits recieved by the tag clients.
  typedef struct packed {
    logic [7:0] data;
  } incr_payload_s;

  parameter bsg_tag_client_num_lp = 1; // Number of tag clients used

  parameter bsg_tag_max_payload_width_lp = 8; // Max width of all bsg_tag_clients 

  ///////////////////////////////
  // Do not touch me!
  //
  parameter bsg_tag_lg_max_payload_width_lp = `BSG_SAFE_CLOG2(bsg_tag_max_payload_width_lp + 1);

endpackage


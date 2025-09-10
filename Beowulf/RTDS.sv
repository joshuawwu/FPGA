module RTDS #(
    parameter BRAKE_THRESHOLD = 12'd2
) (
    input logic clk,
    input logic rst,

    input logic SDC_final,
    input logic [11:0] BSE,         // 12 bit ADC, but can probably go lower
    input logic start_button,       // active high

    output logic brake_light,       // active low
    output logic speaker,           // active low
    output logic ready_to_drive    // active high
);

always_comb begin
    if (BSE > BRAKE_THRESHOLD) begin
        brake_light = 1'b0; // Turn on brake light
    end else begin
        brake_light = 1'b1; // Turn off brake light
    end
end
    
endmodule
module RTDS #(
    parameter BRAKE_THRESHOLD = 12'd2
    parameter SOUND_DURATION = 12'd3000  // Duration for which the sound should play (in clock cycles)
) (
    input logic clk,
    input logic rst,

    input logic SDC_final,
    input logic [11:0] BSE,         // 12 bit ADC, but can probably go lower
    input logic start_button,       // active high

    output logic brake_light,       // active low
    output logic speaker,           // active low
    output logic ready_to_drive     // active high
);

logic [11:0] sound_counter;

typedef enum logic [2:0] {          // i fuck with one hot
    DEFAULT = 3'b001,
    SOUND = 3'b010,
    DRIVE = 3'b100
} state_t;

state_t current_state, next_state;

// state FSM
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        current_state <= DEFAULT;
        sound_counter <= 12b'0;
    end else begin  
        current_state <= next_state;
        if (current_state == SOUND) begin
            sound_counter <= sound_counter + 1;
        end else begin
            sound_counter <= 12'b0;
        end
    end
end

// main logic
always_comb begin
    // default
    next_state = current_state;
    speaker = 1'b1;
    ready_to_drive = 1'b0;

    case (current_state)
        DEFAULT: begin
            if (BSE > BRAKE_THRESHOLD && start_button == 1'b1 && SDC_final == 1'b1) begin
                next_state = SOUND;
            end
        end 
        SOUND: begin
            speaker = 1'b0;
            // ready_to_drive = 1'b1;       // whether or not we do this here is debateable
            if (sound_counter > SOUND_DURATION) begin
                next_state = DRIVE;
            end            
        end
        DRIVE: begin
            ready_to_drive = 1'b1;
            if (SDC_final == 0'b0) begin
                next_state = DEFAULT;
            end
        end
    endcase
end

// brake light
always_comb begin
    if (BSE > BRAKE_THRESHOLD) begin
        brake_light = 1'b0;                 // Turn on brake light
    end else begin
        brake_light = 1'b1;                 // Turn off brake light
    end
end
    
endmodule
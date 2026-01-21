module mastermind (
    input clk,
    input rst,
    input enterA,
    input enterB,
    input [2:0] letterIn,
    output reg [7:0] LEDX,
    output reg [7:0] disp3,
    output reg [7:0] disp2,
    output reg [7:0] disp1,
    output reg [7:0] disp0
  );

  reg [3:0] following_st;

  parameter ST_WAIT           = 4'd0;
  parameter ST_DISPLAY_SCORE  = 4'd1;
  parameter ST_DISPLAY_MAKER  = 4'd2;
  parameter ST_INPUT_CODE     = 4'd3;
  parameter ST_DISPLAY_BREAK  = 4'd4;
  parameter ST_DISPLAY_TRIES  = 4'd5;
  parameter ST_INPUT_GUESS    = 4'd6;
  parameter ST_CHECK_RESULT   = 4'd7;
  parameter ST_REVEAL_CODE    = 4'd8;
  parameter ST_ADD_POINTS     = 4'd9;
  parameter ST_FINISH         = 4'd10;

  parameter [7:0] DISP_OFF   = 8'b1_1111111;
  parameter [7:0] DISP_LINE  = 8'b1_0111111;
  parameter [7:0] DISP_ZERO  = 8'b1_1000000;
  parameter [7:0] DISP_ONE   = 8'b1_1111001;
  parameter [7:0] DISP_TWO   = 8'b1_0100100;
  parameter [7:0] DISP_THREE = 8'b1_0110000;

  parameter [7:0] DISP_A = 8'b1_0001000;
  parameter [7:0] DISP_B = 8'b1_0000011;
  parameter [7:0] DISP_C = 8'b1_1000110;
  parameter [7:0] DISP_E = 8'b1_0000110;
  parameter [7:0] DISP_F = 8'b1_0001110;
  parameter [7:0] DISP_H = 8'b1_0001001;
  parameter [7:0] DISP_L = 8'b1_1000111;
  parameter [7:0] DISP_U = 8'b1_1000001;
  parameter [7:0] DISP_P = 8'b1_0001100;

  parameter [7:0] TIME_SHOW  = 8'd100;
  parameter [7:0] TIME_BLINK = 8'd25;

  reg maker_is_A;
  reg [1:0] points_A;
  reg [1:0] points_B;
  reg [2:0] tries_remaining;
  reg [2:0] input_position;
  reg [7:0] wait_counter;
  reg [2:0] hidden_char_3;
  reg [2:0] hidden_char_2;
  reg [2:0] hidden_char_1;
  reg [2:0] hidden_char_0;
  reg [2:0] guess_char_3;
  reg [2:0] guess_char_2;
  reg [2:0] guess_char_1;
  reg [2:0] guess_char_0;
  reg hidden_input_complete;
  reg guess_input_complete;

  wire maker_btn_signal;
  wire breaker_btn_signal;
  wire timer_expired;
  wire game_finished;
  wire match_all;
  wire no_tries_left;
  wire en_hidden_input;
  wire en_guess_input;
  wire en_score_update_breaker;
  wire en_score_update_maker;
  wire timer_enable;
  wire timer_load;
  wire input_pos_reset;

  reg [1:0] hint_3, hint_2, hint_1, hint_0;
  reg used_h3_temp, used_h2_temp, used_h1_temp, used_h0_temp;

  reg [7:0] hidden_disp_3, hidden_disp_2, hidden_disp_1, hidden_disp_0;
  reg [7:0] guess_disp_3, guess_disp_2, guess_disp_1, guess_disp_0;
  reg [7:0] points_A_disp, points_B_disp, tries_disp;

  assign en_hidden_input = (present_st == ST_INPUT_CODE);
  assign en_guess_input  = (present_st == ST_INPUT_GUESS);

  assign en_score_update_breaker = (present_st == ST_CHECK_RESULT) && (following_st == ST_ADD_POINTS);
  assign en_score_update_maker   = (present_st == ST_REVEAL_CODE) && (following_st == ST_ADD_POINTS);

  assign timer_enable = (present_st == ST_DISPLAY_SCORE) ||
         (present_st == ST_DISPLAY_MAKER) ||
         (present_st == ST_DISPLAY_BREAK) ||
         (present_st == ST_DISPLAY_TRIES) ||
         (present_st == ST_REVEAL_CODE) ||
         (present_st == ST_ADD_POINTS) ||
         (present_st == ST_FINISH) ||
         ((present_st == ST_INPUT_CODE) && (input_position == 3'd4)) ||
         ((present_st == ST_INPUT_GUESS) && (input_position == 3'd4));

  assign timer_load = (present_st != following_st);

  assign input_pos_reset = ((present_st == ST_DISPLAY_MAKER) && (following_st == ST_INPUT_CODE)) ||
         ((present_st == ST_DISPLAY_TRIES) && (following_st == ST_INPUT_GUESS));

  assign maker_btn_signal   = en_hidden_input ? ((maker_is_A == 1'b1) ? enterA : enterB) : 1'b0;
  assign breaker_btn_signal = (en_guess_input || (present_st == ST_CHECK_RESULT)) ? ((maker_is_A == 1'b1) ? enterB : enterA) : 1'b0;

  assign timer_expired = (wait_counter >= TIME_SHOW - 1);
  assign game_finished = ((points_A == 2'd2) || (points_B == 2'd2));

  assign match_all = (hint_3 == 2'b11) && (hint_2 == 2'b11) && (hint_1 == 2'b11) && (hint_0 == 2'b11);
  assign no_tries_left = (tries_remaining == 3'd1) && (!match_all);

  reg [3:0] present_st;

  always @(posedge clk) begin
    if (rst) begin
        present_st <= ST_WAIT;
    end else begin
        present_st <= following_st;
    end
  end
  
  always @(*)
  begin
    following_st = present_st;

    case (present_st)
      ST_WAIT:
      begin
        if ((enterA == 1'b1) || (enterB == 1'b1))
        begin
          following_st = ST_DISPLAY_SCORE;
        end
      end

      ST_DISPLAY_SCORE:
      begin
        if (timer_expired == 1'b1)
        begin
          following_st = ST_DISPLAY_MAKER;
        end
      end

      ST_DISPLAY_MAKER:
      begin
        if (timer_expired == 1'b1)
        begin
          following_st = ST_INPUT_CODE;
        end
      end

      ST_INPUT_CODE:
      begin
        if ((hidden_input_complete == 1'b1) && ((input_position != 3'd4) || (timer_expired == 1'b1)))
        begin
          following_st = ST_DISPLAY_BREAK;
        end
      end

      ST_DISPLAY_BREAK:
      begin
        if (timer_expired == 1'b1)
        begin
          following_st = ST_DISPLAY_TRIES;
        end
      end

      ST_DISPLAY_TRIES:
      begin
        if (timer_expired == 1'b1)
        begin
          following_st = ST_INPUT_GUESS;
        end
      end

      ST_INPUT_GUESS:
      begin
        if ((guess_input_complete == 1'b1) && ((input_position != 3'd4) || (timer_expired == 1'b1)))
        begin
          following_st = ST_CHECK_RESULT;
        end
      end

      ST_CHECK_RESULT:
      begin
        if (breaker_btn_signal == 1'b1)
        begin
          if (match_all == 1'b1)
          begin
            following_st = ST_ADD_POINTS;
          end
          else if (no_tries_left == 1'b1)
          begin
            following_st = ST_REVEAL_CODE;
          end
          else
          begin
            following_st = ST_DISPLAY_TRIES;
          end
        end
      end

      ST_REVEAL_CODE:
      begin
        if (timer_expired == 1'b1)
        begin
          following_st = ST_ADD_POINTS;
        end
      end

      ST_ADD_POINTS:
      begin
        if (timer_expired == 1'b1)
        begin
          if (game_finished == 1'b1)
          begin
            following_st = ST_FINISH;
          end
          else
          begin
            following_st = ST_DISPLAY_SCORE;
          end
        end
      end

      ST_FINISH:
      begin
        if ((enterA == 1'b1) || (enterB == 1'b1))
        begin
          following_st = ST_WAIT;
        end
      end

      default:
      begin
        following_st = ST_WAIT;
      end
    endcase
  end

  always @(posedge clk)
  begin
    if (rst) begin
        wait_counter <= 8'd0;
    end
    else if (timer_load) begin
        wait_counter <= 8'd0;
    end
    else if (timer_enable) begin
        if (wait_counter >= TIME_SHOW - 1)
            wait_counter <= 8'd0;
        else
            wait_counter <= wait_counter + 1;
    end
    else begin
        wait_counter <= 8'd0;
    end
  end

  always @(posedge clk)
  begin
    if (rst)
    begin
      maker_is_A <= 1'b1;
      points_A <= 2'd0;
      points_B <= 2'd0;
      tries_remaining <= 3'd3;
      input_position <= 3'd0;

      hidden_char_3 <= 3'd0;
      hidden_char_2 <= 3'd0;
      hidden_char_1 <= 3'd0;
      hidden_char_0 <= 3'd0;

      guess_char_3 <= 3'd0;
      guess_char_2 <= 3'd0;
      guess_char_1 <= 3'd0;
      guess_char_0 <= 3'd0;

      hidden_input_complete <= 1'b0;
      guess_input_complete <= 1'b0;
    end
    else
    begin
      if (present_st == ST_WAIT)
      begin
        if ((enterA == 1'b1) && (enterB == 1'b0))
        begin
          maker_is_A <= 1'b1;
          points_A <= 2'd0;
          points_B <= 2'd0;
          tries_remaining <= 3'd3;
        end
        else if ((enterB == 1'b1) && (enterA == 1'b0))
        begin
          maker_is_A <= 1'b0;
          points_A <= 2'd0;
          points_B <= 2'd0;
          tries_remaining <= 3'd3;
        end
        else if ((enterA == 1'b1) && (enterB == 1'b1))
        begin
          maker_is_A <= 1'b1;
          points_A <= 2'd0;
          points_B <= 2'd0;
          tries_remaining <= 3'd3;
        end
      end

      if (present_st != following_st)
      begin
        if (following_st == ST_INPUT_CODE || following_st == ST_INPUT_GUESS)
          input_position <= 3'd0;
      end

      if (present_st != ST_INPUT_CODE)
      begin
        hidden_input_complete <= 1'b0;
      end

      if (present_st != ST_INPUT_GUESS)
      begin
        guess_input_complete <= 1'b0;
      end

      if (input_pos_reset)
        input_position <= 3'd0;

      if ((present_st == ST_DISPLAY_MAKER) && (following_st == ST_INPUT_CODE))
      begin
        hidden_char_3 <= 3'd0;
        hidden_char_2 <= 3'd0;
        hidden_char_1 <= 3'd0;
        hidden_char_0 <= 3'd0;
      end

      if (en_hidden_input)
      begin
        if ((maker_btn_signal == 1'b1) && (letterIn != 3'd0))
        begin
          case (input_position)
            3'd0:
            begin
              hidden_char_3 <= letterIn;
              input_position <= 3'd1;
            end
            3'd1:
            begin
              hidden_char_2 <= letterIn;
              input_position <= 3'd2;
            end
            3'd2:
            begin
              hidden_char_1 <= letterIn;
              input_position <= 3'd3;
            end
            3'd3:
            begin
              hidden_char_0 <= letterIn;
              input_position <= 3'd4;
              hidden_input_complete <= 1'b1;
            end
            default:
            begin
              input_position <= 3'd0;
            end
          endcase
        end
      end

      if ((present_st == ST_DISPLAY_TRIES) && (following_st == ST_INPUT_GUESS))
      begin
        guess_char_3 <= 3'd0;
        guess_char_2 <= 3'd0;
        guess_char_1 <= 3'd0;
        guess_char_0 <= 3'd0;
      end

      if (en_guess_input)
      begin
        if ((breaker_btn_signal == 1'b1) && (letterIn != 3'd0))
        begin
          case (input_position)
            3'd0:
            begin
              guess_char_3 <= letterIn;
              input_position <= 3'd1;
            end
            3'd1:
            begin
              guess_char_2 <= letterIn;
              input_position <= 3'd2;
            end
            3'd2:
            begin
              guess_char_1 <= letterIn;
              input_position <= 3'd3;
            end
            3'd3:
            begin
              guess_char_0 <= letterIn;
              input_position <= 3'd4;
              guess_input_complete <= 1'b1;
            end
            default:
            begin
              input_position <= 3'd0;
            end
          endcase
        end
      end

      if (en_score_update_breaker)
      begin
        if (maker_is_A)
          points_B <= points_B + 2'd1;
        else
          points_A <= points_A + 2'd1;
      end

      if ((present_st == ST_CHECK_RESULT) && (following_st == ST_DISPLAY_TRIES))
        tries_remaining <= tries_remaining - 3'd1;

      if (en_score_update_maker)
      begin
        if (maker_is_A)
          points_A <= points_A + 2'd1;
        else
          points_B <= points_B + 2'd1;
      end

      if ((present_st == ST_ADD_POINTS) && (following_st == ST_DISPLAY_SCORE))
      begin
        maker_is_A <= ~maker_is_A;
        tries_remaining <= 3'd3;
        input_position <= 3'd0;
        hidden_char_3 <= 3'd0;
        hidden_char_2 <= 3'd0;
        hidden_char_1 <= 3'd0;
        hidden_char_0 <= 3'd0;
        guess_char_3 <= 3'd0;
        guess_char_2 <= 3'd0;
        guess_char_1 <= 3'd0;
        guess_char_0 <= 3'd0;
      end

      if ((present_st == ST_FINISH) && (following_st == ST_WAIT))
      begin
        points_A <= 2'd0;
        points_B <= 2'd0;
        tries_remaining <= 3'd3;
        input_position <= 3'd0;
      end
    end
  end

  always @(*)
  begin
    used_h3_temp = 1'b0;
    used_h2_temp = 1'b0;
    used_h1_temp = 1'b0;
    used_h0_temp = 1'b0;

    hint_3 = 2'b00;
    hint_2 = 2'b00;
    hint_1 = 2'b00;
    hint_0 = 2'b00;

    if ((guess_char_3 == hidden_char_3) && (guess_char_3 != 3'd0))
    begin
      hint_3 = 2'b11;
      used_h3_temp = 1'b1;
    end

    if ((guess_char_2 == hidden_char_2) && (guess_char_2 != 3'd0))
    begin
      hint_2 = 2'b11;
      used_h2_temp = 1'b1;
    end

    if ((guess_char_1 == hidden_char_1) && (guess_char_1 != 3'd0))
    begin
      hint_1 = 2'b11;
      used_h1_temp = 1'b1;
    end

    if ((guess_char_0 == hidden_char_0) && (guess_char_0 != 3'd0))
    begin
      hint_0 = 2'b11;
      used_h0_temp = 1'b1;
    end

    if ((hint_3 != 2'b11) && (guess_char_3 != 3'd0))
    begin
      if ((guess_char_3 == hidden_char_2) && (used_h2_temp == 1'b0))
      begin
        hint_3 = 2'b01;
        used_h2_temp = 1'b1;
      end
      else if ((guess_char_3 == hidden_char_1) && (used_h1_temp == 1'b0))
      begin
        hint_3 = 2'b01;
        used_h1_temp = 1'b1;
      end
      else if ((guess_char_3 == hidden_char_0) && (used_h0_temp == 1'b0))
      begin
        hint_3 = 2'b01;
        used_h0_temp = 1'b1;
      end
    end

    if ((hint_2 != 2'b11) && (guess_char_2 != 3'd0))
    begin
      if ((guess_char_2 == hidden_char_3) && (used_h3_temp == 1'b0))
      begin
        hint_2 = 2'b01;
        used_h3_temp = 1'b1;
      end
      else if ((guess_char_2 == hidden_char_1) && (used_h1_temp == 1'b0))
      begin
        hint_2 = 2'b01;
        used_h1_temp = 1'b1;
      end
      else if ((guess_char_2 == hidden_char_0) && (used_h0_temp == 1'b0))
      begin
        hint_2 = 2'b01;
        used_h0_temp = 1'b1;
      end
    end

    if ((hint_1 != 2'b11) && (guess_char_1 != 3'd0))
    begin
      if ((guess_char_1 == hidden_char_3) && (used_h3_temp == 1'b0))
      begin
        hint_1 = 2'b01;
        used_h3_temp = 1'b1;
      end
      else if ((guess_char_1 == hidden_char_2) && (used_h2_temp == 1'b0))
      begin
        hint_1 = 2'b01;
        used_h2_temp = 1'b1;
      end
      else if ((guess_char_1 == hidden_char_0) && (used_h0_temp == 1'b0))
      begin
        hint_1 = 2'b01;
        used_h0_temp = 1'b1;
      end
    end

    if ((hint_0 != 2'b11) && (guess_char_0 != 3'd0))
    begin
      if ((guess_char_0 == hidden_char_3) && (used_h3_temp == 1'b0))
      begin
        hint_0 = 2'b01;
        used_h3_temp = 1'b1;
      end
      else if ((guess_char_0 == hidden_char_2) && (used_h2_temp == 1'b0))
      begin
        hint_0 = 2'b01;
        used_h2_temp = 1'b1;
      end
      else if ((guess_char_0 == hidden_char_1) && (used_h1_temp == 1'b0))
      begin
        hint_0 = 2'b01;
        used_h1_temp = 1'b1;
      end
    end
  end

  always @(*)
  begin
    case (hidden_char_3)
      3'b001:
        hidden_disp_3 = DISP_A;
      3'b010:
        hidden_disp_3 = DISP_C;
      3'b011:
        hidden_disp_3 = DISP_E;
      3'b100:
        hidden_disp_3 = DISP_F;
      3'b101:
        hidden_disp_3 = DISP_H;
      3'b110:
        hidden_disp_3 = DISP_L;
      3'b111:
        hidden_disp_3 = DISP_U;
      default:
        hidden_disp_3 = DISP_OFF;
    endcase

    case (hidden_char_2)
      3'b001:
        hidden_disp_2 = DISP_A;
      3'b010:
        hidden_disp_2 = DISP_C;
      3'b011:
        hidden_disp_2 = DISP_E;
      3'b100:
        hidden_disp_2 = DISP_F;
      3'b101:
        hidden_disp_2 = DISP_H;
      3'b110:
        hidden_disp_2 = DISP_L;
      3'b111:
        hidden_disp_2 = DISP_U;
      default:
        hidden_disp_2 = DISP_OFF;
    endcase

    case (hidden_char_1)
      3'b001:
        hidden_disp_1 = DISP_A;
      3'b010:
        hidden_disp_1 = DISP_C;
      3'b011:
        hidden_disp_1 = DISP_E;
      3'b100:
        hidden_disp_1 = DISP_F;
      3'b101:
        hidden_disp_1 = DISP_H;
      3'b110:
        hidden_disp_1 = DISP_L;
      3'b111:
        hidden_disp_1 = DISP_U;
      default:
        hidden_disp_1 = DISP_OFF;
    endcase

    case (hidden_char_0)
      3'b001:
        hidden_disp_0 = DISP_A;
      3'b010:
        hidden_disp_0 = DISP_C;
      3'b011:
        hidden_disp_0 = DISP_E;
      3'b100:
        hidden_disp_0 = DISP_F;
      3'b101:
        hidden_disp_0 = DISP_H;
      3'b110:
        hidden_disp_0 = DISP_L;
      3'b111:
        hidden_disp_0 = DISP_U;
      default:
        hidden_disp_0 = DISP_OFF;
    endcase
  end

  always @(*)
  begin
    case (guess_char_3)
      3'b001:
        guess_disp_3 = DISP_A;
      3'b010:
        guess_disp_3 = DISP_C;
      3'b011:
        guess_disp_3 = DISP_E;
      3'b100:
        guess_disp_3 = DISP_F;
      3'b101:
        guess_disp_3 = DISP_H;
      3'b110:
        guess_disp_3 = DISP_L;
      3'b111:
        guess_disp_3 = DISP_U;
      default:
        guess_disp_3 = DISP_OFF;
    endcase

    case (guess_char_2)
      3'b001:
        guess_disp_2 = DISP_A;
      3'b010:
        guess_disp_2 = DISP_C;
      3'b011:
        guess_disp_2 = DISP_E;
      3'b100:
        guess_disp_2 = DISP_F;
      3'b101:
        guess_disp_2 = DISP_H;
      3'b110:
        guess_disp_2 = DISP_L;
      3'b111:
        guess_disp_2 = DISP_U;
      default:
        guess_disp_2 = DISP_OFF;
    endcase

    case (guess_char_1)
      3'b001:
        guess_disp_1 = DISP_A;
      3'b010:
        guess_disp_1 = DISP_C;
      3'b011:
        guess_disp_1 = DISP_E;
      3'b100:
        guess_disp_1 = DISP_F;
      3'b101:
        guess_disp_1 = DISP_H;
      3'b110:
        guess_disp_1 = DISP_L;
      3'b111:
        guess_disp_1 = DISP_U;
      default:
        guess_disp_1 = DISP_OFF;
    endcase

    case (guess_char_0)
      3'b001:
        guess_disp_0 = DISP_A;
      3'b010:
        guess_disp_0 = DISP_C;
      3'b011:
        guess_disp_0 = DISP_E;
      3'b100:
        guess_disp_0 = DISP_F;
      3'b101:
        guess_disp_0 = DISP_H;
      3'b110:
        guess_disp_0 = DISP_L;
      3'b111:
        guess_disp_0 = DISP_U;
      default:
        guess_disp_0 = DISP_OFF;
    endcase
  end

  always @(*)
  begin
    case (points_A)
      2'd0:
        points_A_disp = DISP_ZERO;
      2'd1:
        points_A_disp = DISP_ONE;
      2'd2:
        points_A_disp = DISP_TWO;
      default:
        points_A_disp = DISP_ZERO;
    endcase

    case (points_B)
      2'd0:
        points_B_disp = DISP_ZERO;
      2'd1:
        points_B_disp = DISP_ONE;
      2'd2:
        points_B_disp = DISP_TWO;
      default:
        points_B_disp = DISP_ZERO;
    endcase

    case (tries_remaining)
      3'd3:
        tries_disp = DISP_THREE;
      3'd2:
        tries_disp = DISP_TWO;
      3'd1:
        tries_disp = DISP_ONE;
      default:
        tries_disp = DISP_ZERO;
    endcase
  end

  always @(*)
  begin
    LEDX = 8'b00000000;
    disp3 = DISP_OFF;
    disp2 = DISP_OFF;
    disp1 = DISP_LINE;
    disp0 = DISP_OFF;

    case (present_st)
      ST_WAIT:
      begin
        disp3 = DISP_OFF;
        disp2 = DISP_A;
        disp1 = DISP_LINE;
        disp0 = DISP_B;
        LEDX = 8'b00000000;
      end

      ST_DISPLAY_SCORE:
      begin
        disp3 = DISP_OFF;
        disp2 = points_A_disp;
        disp1 = DISP_LINE;
        disp0 = points_B_disp;
        LEDX = 8'b00000000;
      end

      ST_DISPLAY_MAKER:
      begin
        disp3 = DISP_OFF;
        disp2 = DISP_P;
        disp1 = DISP_LINE;
        if (maker_is_A == 1'b1)
        begin
          disp0 = DISP_A;
        end
        else
        begin
          disp0 = DISP_B;
        end
        LEDX = 8'b00000000;
      end

      ST_DISPLAY_BREAK:
      begin
        disp3 = DISP_OFF;
        disp2 = DISP_P;
        disp1 = DISP_LINE;
        if (maker_is_A == 1'b1)
        begin
          disp0 = DISP_B;
        end
        else
        begin
          disp0 = DISP_A;
        end
        LEDX = 8'b00000000;
      end

      ST_DISPLAY_TRIES:
      begin
        disp3 = DISP_OFF;
        disp2 = DISP_L;
        disp1 = DISP_LINE;
        disp0 = tries_disp;
        LEDX = 8'b00000000;
      end

      ST_INPUT_CODE:
      begin
        case (input_position)
          3'd0:
          begin
            disp3 = DISP_OFF;
            disp2 = DISP_OFF;
            disp1 = DISP_OFF;
            disp0 = DISP_OFF;
          end
          3'd1:
          begin
            disp3 = hidden_disp_3;
            disp2 = DISP_OFF;
            disp1 = DISP_OFF;
            disp0 = DISP_OFF;
          end
          3'd2:
          begin
            disp3 = DISP_LINE;
            disp2 = hidden_disp_2;
            disp1 = DISP_OFF;
            disp0 = DISP_OFF;
          end
          3'd3:
          begin
            disp3 = DISP_LINE;
            disp2 = DISP_LINE;
            disp1 = hidden_disp_1;
            disp0 = DISP_OFF;
          end
          3'd4:
          begin
            disp3 = DISP_LINE;
            disp2 = DISP_LINE;
            disp1 = DISP_LINE;
            disp0 = hidden_disp_0;
          end
          default:
          begin
            disp3 = DISP_OFF;
            disp2 = DISP_OFF;
            disp1 = DISP_OFF;
            disp0 = DISP_OFF;
          end
        endcase
        LEDX = 8'b00000000;
      end

      ST_INPUT_GUESS:
      begin
        if (guess_char_3 != 3'd0)
        begin
          disp3 = guess_disp_3;
        end
        else
        begin
          disp3 = DISP_OFF;
        end

        if (guess_char_2 != 3'd0)
        begin
          disp2 = guess_disp_2;
        end
        else
        begin
          disp2 = DISP_OFF;
        end

        if (guess_char_1 != 3'd0)
        begin
          disp1 = guess_disp_1;
        end
        else
        begin
          disp1 = DISP_OFF;
        end

        if (guess_char_0 != 3'd0)
        begin
          disp0 = guess_disp_0;
        end
        else
        begin
          disp0 = DISP_OFF;
        end

        LEDX = 8'b00000000;
      end

      ST_CHECK_RESULT:
      begin
        disp3 = guess_disp_3;
        disp2 = guess_disp_2;
        disp1 = guess_disp_1;
        disp0 = guess_disp_0;
        LEDX = {hint_3, hint_2, hint_1, hint_0};
      end

      ST_REVEAL_CODE:
      begin
        disp3 = hidden_disp_3;
        disp2 = hidden_disp_2;
        disp1 = hidden_disp_1;
        disp0 = hidden_disp_0;
        LEDX = 8'b00000000;
      end

      ST_ADD_POINTS:
      begin
        disp3 = DISP_OFF;
        disp2 = points_A_disp;
        disp1 = DISP_LINE;
        disp0 = points_B_disp;
        LEDX = 8'b00000000;
      end

      ST_FINISH:
      begin
        disp3 = DISP_OFF;
        disp2 = points_A_disp;
        disp1 = DISP_LINE;
        disp0 = points_B_disp;
        if (wait_counter < TIME_BLINK)
        begin
          LEDX = 8'b11111111;
        end
        else
        begin
          LEDX = 8'b00000000;
        end
      end

      default:
      begin
        disp3 = DISP_OFF;
        disp2 = DISP_OFF;
        disp1 = DISP_LINE;
        disp0 = DISP_OFF;
        LEDX = 8'b00000000;
      end
    endcase
  end

endmodule

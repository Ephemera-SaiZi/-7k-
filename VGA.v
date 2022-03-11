`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/20 20:11:43
// Design Name: 
// Module Name: vga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga(
    input   clk,               //25MHZʱ��
    input   rst,               //��λ
    input   rst_track,         //
    input [7:0] keys,          //7������
    input key_state,           //����״̬
    input [3:0] music_id,      //�ڼ��׸�
        //rgb��ͨ��
    output reg [3:0]    color_r,    //R
    output reg [3:0]    color_g,    //G
    output reg [3:0]    color_b,    //B
    output              hs,         //��ͬ��
    output              vs,         //��ͬ��
    output [31:0]   score,          //����
    output [15:0]       debugled    //����led�ƽ��е���
    );
    //��ʱ����
    parameter   HS_SYNC     = 136,   
                HS_BACK     = 160,   
                HS_ACTIVE   = 1024,  
                HS_FRONT    = 24;   
    //��ʱ����
    parameter   VS_SYNC     = 6,    
                VS_BACK     = 29,   
                VS_ACTIVE   = 768,  
                VS_FRONT    = 3;   
    //�������
    parameter   COL = 1344,
                        ROW = 806;
    //������
    reg [11:0]  h_cnt = 12'd0;      //�м�����
    reg [11:0]  v_cnt = 12'd0;      //��������
    //������ת����
    wire [11:0] x;
    wire [11:0] y;//����
    wire active;//��ʾ�Ƿ����

    //������
    wire [639:0] track0;
    wire [639:0] track1;
    wire [639:0] track2;
    wire [639:0] track3;
    wire [639:0] track4;
    wire [639:0] track5;
    wire [639:0] track6;
    //�÷ַ���
    wire [3:0]msg;
    //��ʼ��ʾ
    always @(posedge clk) begin
        if(active) begin
            //��Ч��ʾ����
            if(x >= 7 && x < 1010 && y >= 30 && y < 735) begin
                //��������
                if((y<670)&&
                    ((track0[y-30]&&x>=17 && x<17+140)||
                    (track1[y-30]&&x>=17+140*1 && x<17+140*2)||
                    (track2[y-30]&&x>=17+140*2 && x<17+140*3)||
                    (track3[y-30]&&x>=17+140*3 && x<17+140*4)||
                    (track4[y-30]&&x>=17+140*4 && x<17+140*5)||
                    (track5[y-30]&&x>=17+140*5 && x<17+140*6)||
                    (track6[y-30]&&x>=17+140*6))) begin
                        color_r <= 4'd15; color_g <= 4'd10; color_b <= 4'd10; 
                end
                //��������
                else begin
                    //�������
                    //����߿�
                    if((x>=7 && x<17)||(x>=1000)) begin
                        color_r <= 4'd8;color_g <= 4'd11;color_b <= 4'd12; 
                    end
                    //����ָ�
                    else if(x==17+140 || x==17+140*2 || x==17+140*3 || x==17+140*4 || x==17+140*5 ||x==17+140*6) begin
                            color_r <= 4'd15;color_g <= 4'd15;color_b <= 4'd15;
                    end
                    //�ж���
                    else if(y>=670) begin
                        color_r <= 4'd8;color_g <= 4'd15;color_b <= 4'd8;
                    end
                    //���7Keys
                    else begin
                        //��������
                        if( (keys==8'h5a&& x>=17 && x<17+140)||
                            (keys==8'h58 && x>=17+140 && x<17+140*2)||
                            (keys==8'h43 && x>=17+140*2 && x<17+140*3)||
                            (keys==8'h56 && x>=17+140*3 && x<17+140*4)||
                            (keys==8'h42 && x>=17+140*4 && x<17+140*5)||
                            (keys==8'h4e && x>=17+140*5 && x<17+140*6)||
                            (keys==8'h4d && x>=17+140*6)) begin
                                color_r <= 4'd6;color_g <= 4'd6;color_b <= 4'd8; 
                        end
                        //Ĭ�����
                        else begin
                            color_r <= 4'd2;color_g <= 4'd2;color_b <= 4'd2;                    
                        end
                    end
                end
            end
            //�����һ��(������ɫ)
            else begin
                case (msg)
                4'd0:begin//lost
                    color_r <= 4'd15;color_g <= 4'd0;color_b <= 4'd0;
                end
                4'd1:begin//bad
                    color_r <= 4'd15;color_g <= 4'd15;color_b <= 4'd2;
                end
                4'd2:begin//far
                    color_r <= 4'd4;color_g <= 4'd14;color_b <= 4'd5;
                end
                4'd3:begin//pure
                    color_r <= 4'd15;color_g <= 4'd3;color_b <= 4'd15;
                end
                default:begin
                    color_r <= 4'd15;color_g <= 4'd15;color_b <= 4'd15;
                    end
                endcase          
            end
        end
        else begin
                color_r = 4'd0;color_g = 4'd0;color_b = 4'd0;
        end
    end

    //���������������
    track_control uut_track(
        .clk(clk),
        .rst(rst_track),
        .keys(keys),            //��������
        .key_state(key_state),  //���̰���״̬
        .msg(msg),              //�÷ַ���
        .music_id(music_id),    //����ѡ��
        .track0(track0),
        .track1(track1),
        .track2(track2),
        .track3(track3),
        .track4(track4),
        .track5(track5),
        .track6(track6),
        .score(score),
        .debugled(debugled)
    );

    //��ͬ��ѭ��
    always @(posedge clk or negedge rst) begin
        if(!rst)
            h_cnt <= 12'd0;
        else if(h_cnt == COL-1)
            h_cnt <= 12'd0;
        else
            h_cnt <= h_cnt + 1'b1;
    end

    //��ͬ��ѭ��
    always @(posedge clk or negedge rst) begin
        if(!rst)
            v_cnt <= 12'd0;
        else if(v_cnt == ROW-1)
            v_cnt <= 12'd0;
        else if(h_cnt == COL-1)
            v_cnt <= v_cnt + 1'b1;
        else
            v_cnt <= v_cnt;
    end

    //�����ͬ������ͬ��
    assign hs = (h_cnt < HS_SYNC)? 1'b0 : 1'b1;
    assign vs = (v_cnt < VS_SYNC)? 1'b0 : 1'b1;
    assign active =  (h_cnt >= (HS_SYNC + HS_BACK))  &&                 
                    (h_cnt <= (HS_SYNC + HS_BACK + HS_ACTIVE))  && 
                    (v_cnt >= (VS_SYNC + VS_BACK))  &&
                    (v_cnt <= (VS_SYNC + VS_BACK + VS_ACTIVE))  ;

    assign x = (active) ? h_cnt - (HS_SYNC + HS_BACK):0;
    assign y = (active) ? v_cnt - (VS_SYNC + VS_BACK):0;
endmodule




`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/05 21:36:27
// Design Name: 
// Module Name: VGA_TOP
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


module GAME_TOP(
    input   clk_100,               //100Mhz
    //����
    input   key_clk,                //����ʱ��
    input   key_data,              //������������
    //��λ����
    input   rst,                    //��λ
    input   rst_track,              //�����λ
    //VGA
    input [3:0] music_id,      //�ڼ��׸�
    output [3:0]    color_r,    //R
    output [3:0]    color_g,    //G
    output [3:0]    color_b,    //B
    output              hs,         //��ͬ??
    output              vs,         //��ͬ??
    //�߶������
    output [7:0] shift,
    output [6:0] oData,
    //MP3
    input        SO,             //����
    input        DREQ,           //�������󣬸ߵ�ƽʱ�ɴ�������
    output      XCS,            //Ƭ???SCI �����???дָ��
    output      XDCS,           //Ƭ???SDI ��������
    output      SCK,            //ʱ��
    output      SI,             //����mp3
    output  XRESET,         //Ӳ����λ���͵�ƽ��Ч
    output [15:0]  debugled
    );
    //ʱ��
    wire clk_65,clk_12,clk_1000,clk_2,locked;
    //��������
    wire [8:0] keys;
    wire key_state;
    //�÷�
    wire [31:0] score;

    //��Ƶ1
    clk_wiz_0 uut(
        .reset(~rst),
        .locked(locked),
        .clk_in1(clk_100),
        .clk_out1(clk_65),
        .clk_out2(clk_12)
    );
    //��Ƶ��2
    Divider uut_divider(
        .clk12Mhz(clk_12),
        .clk1000hz(clk_1000),
        .clk2Mhz(clk_2)
    );

    //VGA
    vga uut_vga(
        .clk(clk_65),
        .rst(locked),
        .rst_track(rst_track),
        .music_id(music_id),
        .keys(keys),
        .key_state(key_state),
        .color_r(color_r),
        .color_g(color_g),
        .color_b(color_b),
        .hs(hs),
        .vs(vs),
        .score(score),
        .debugled(debugled)
    );

    //MP3
    mp3board uut_mp3(
        .clk(clk_2),
        .rst(rst),
        .play(rst_track),
        .SO(SO),
        .DREQ(DREQ),
        .XCS(XCS),
        .XDCS(XDCS),
        .SCK(SCK),
        .SI(SI),
        .XRESET(XRESET),
        .music_id(music_id)
    );
    
    //����
    keyboard uut_keyboard(
        .clk_in(clk_100),
        .rst(rst),
        .key_clk(key_clk),
        .key_data(key_data),
        .key_state(key_state),
        .key_ascii(keys)
    );

    //�������ʾ����
    display_score uut_score(
        .clk_1000hz(clk_1000),
        .score(score),
        .shift(shift),//�ڼ��������(Ƭѡ)
        .oData(oData)
    );

endmodule

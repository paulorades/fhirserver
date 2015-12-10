object FHIRPathDebuggerForm: TFHIRPathDebuggerForm
  Left = 0
  Top = 0
  BorderIcons = [biMaximize]
  Caption = 'FHIR Path Debugger'
  ClientHeight = 495
  ClientWidth = 772
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 720
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 67
    Width = 772
    Height = 3
    Cursor = crVSplit
    Align = alTop
    OnMoved = Splitter1Moved
    ExplicitWidth = 561
  end
  object Panel1: TPanel
    Left = 0
    Top = 450
    Width = 772
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      772
      45)
    object btnStop: TBitBtn
      Left = 651
      Top = 6
      Width = 113
      Height = 33
      Anchors = [akTop, akRight]
      Caption = 'Stop (F2)'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
        FF00FFFF00FFFF00FF01079F0313A90418AE0419AE0313A90108A0FF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF01049D041CB10730C00734C407
        35C50735C50734C30731C1041FB301069EFF00FFFF00FFFF00FFFF00FFFF00FF
        0109A1052BC30735C70733C20732C20732C20732C20732C20733C30735C4062D
        BE020CA4FF00FFFF00FFFF00FF01049B052BCA0636D80431CD0027C4032EC107
        32C20732C20430C10027BF042FC10735C4072EBE01069EFF00FFFF00FF031ABA
        0537E70331DD123DD86480E01840CB002CC1022DC00F38C46580D91B43C7052F
        C10735C5051FB3FF00FF01049E0430E40436F1002AE45070E9FFFFFFB7C4F10D
        36CA042DC3A2B2E8FFFFFF6984DA0026BE0733C30731C10108A0020FAF0336FA
        0335F80232EE0A35E88CA2F2FFFFFFB4C2F1A9B8EDFFFFFFA7B7E9133AC4052F
        C10732C20734C40313AA0619BC1747FE093AFC0435F80131F0002BE891A5F4FF
        FFFFFFFFFFABBAEF062FC5022DC00732C20732C20736C50419AE0B1DBE4168FE
        1C49FC0335FB0031F90531F2A4B5F7FFFFFFFFFFFFB9C6F20D36D0002CC60732
        C20732C20736C50418AD0613B45B7CFC486CFD0133FB113CFBA1B4FEFFFFFFA4
        B6F892A7F5FFFFFFB6C4F21A41D3042FC80732C40734C30212A90003A04A6AF3
        8FA6FF1F46FB4C6FFCFFFFFFA7B8FE0733F6002AED8CA2F6FFFFFF627FE70028
        D00734CC0730C300069FFF00FF1A2FCB99AFFF8BA2FE214DFB4D71FC0E3DFB00
        30FB0031F70636F14C6EF1103CE30432DB0636D7041CB5FF00FFFF00FF0004A0
        415EECB8C7FF9CAFFD3A5CFC0A3AFB0335FB0335FB0133F9052FF20635EB0537
        E9052CCD00049CFF00FFFF00FFFF00FF0309A54260ECA9BBFFBDCAFF8EA5FE64
        83FD5073FC4A6EFD3961FD1444F9042CD70109A2FF00FFFF00FFFF00FFFF00FF
        FF00FF0004A01E32CD5876F6859EFE8BA3FF7994FE5376FC234AF0051EC50104
        9CFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0004A00917B610
        22C30D1FC20311B401059FFF00FFFF00FFFF00FFFF00FFFF00FF}
      TabOrder = 0
      OnClick = btnStopClick
    end
    object btnNext: TBitBtn
      Left = 294
      Top = 6
      Width = 113
      Height = 33
      Anchors = [akTop, akRight]
      Caption = 'Next (F7)'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
        FF00FFFF00FFFF00FF044906055B09066C0C066C0C055E0A044C06FF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF05600905600908911309B01809
        B31A09B31909B11907961405680C05680CFF00FFFF00FFFF00FFFF00FFFF00FF
        0A6A150A7F150BB61C09B91A08B41807B21609B31909B41909B81A09B91A0783
        10044D06FF00FFFF00FFFF00FF0B6A150F852216BD3411B7270BB21C07B11608
        B11709B21909B21909B21909B41909BA1A07841006670CFF00FFFF00FF0B6A15
        20BE491BBD4014B7300AB21F28BC36DFF5E1EEFAEF63CE6D09B21909B21909B3
        1909BA1A06670CFF00FF0872101B9A3A2AC65B1DBB450EB4250BB31B11B4219A
        DFA0FFFFFFF7FDF85ACB6509B21909B21909B81A089413045D090872102AB65B
        2CC56522BD4D0FB4220AB21A0CB31C0AB2198DDB95FDFEFDF6FCF758CB6309B2
        1909B51A08AB17045D090F821C37C26C33C76CCDF1DAC9EFD3C7EED0C8EFD2C5
        EED0C7EECFF8FDF9FFFFFFF2FBF36FD27908B41909B31905650B138D2358CC83
        42C977FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFEFDFFFFFFFFFFFFBCEA
        C10AB41A09B319066D0D0F911D6FD2935FD38D6DD49572D69971D69872D69964
        D28C92DFA8FBFEFBFFFFFFACE5B82EBF4C11B82B08B11905610A0F911D67CC83
        9BE5BA38C67030C36938C56F38C56F70D697E8F8EEFFFFFF9FE2B120BD481AB9
        3E10BA2908A31705610AFF00FF25AE39BCEDD282DBA428C0632FC26753CD82F7
        FDF9FFFFFF9CE2B222BC4B1DBA4118B73614C0300A8517FF00FFFF00FF25AE39
        71D28CD2F4E180DAA336C46D39C56FBCECCEABE6C22DC26324BE5623BC4D1FC1
        4616AE340A8517FF00FFFF00FFFF00FF25AE3984D89FDBF7EAAFE8C66BD49352
        CC8144C97849CA7B48CB7839CB6A21B6490F7C1FFF00FFFF00FFFF00FFFF00FF
        FF00FF25AE3925AE39ADE8C5CCF2DEBAEDD1A6E7C291E2B364D4922FB1572FB1
        57FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF32B74E25AE3925
        AE3925AE3925AE3924A342FF00FFFF00FFFF00FFFF00FFFF00FF}
      TabOrder = 1
      OnClick = btnNextClick
    end
    object btnSkip: TBitBtn
      Left = 413
      Top = 6
      Width = 113
      Height = 33
      Anchors = [akTop, akRight]
      Caption = 'Skip this (F8)'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000130B0000130B00000000000000000001FF00FFFF00FF
        FF00FFFF00FFFF00FF009BCD029FD102A1D302A0D2019CCF009ACDFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF009ACD05A9DB08B5E508B7E708
        B6E607B3E306AEDF04A7D9029FD10099CCFF00FFFF00FFFF00FFFF00FFFF00FF
        019DCF09B8E80CC4F30CC4F30CC3F20BC1F00BBEED09B9E907B3E406ADDD03A3
        D5009ACDFF00FFFF00FFFF00FF019ACD0ABDEC0ECDFA0FCEFC11D0FC11D0FC0E
        CDFB0DCAF80CC4F30BBEED08B6E605ADDE02A3D50099CCFF00FFFF00FF06B0E1
        12D3FE1CD6FE28DAFE2FDCFE2EDCFE26D9FE19D4FE10CFFC0DC7F50ABEED08B5
        E505ABDC019ED0FF00FF009BCE11CBF829DCFF3EE1FE4DE6FE54E8FE54E8FE4A
        E5FE39E0FE23D8FE11D0FC0CC6F50ABCEC07B2E203A5D7009ACC04A5D627DAFF
        45E4FE5DECFE6FF2FE78F5FE77F4FE6BF0FE58EAFE3FE1FE21D8FE0ECDFA0CC2
        F109B7E705ABDC019CCF0BACDB3BE2FF5BEBFE78F5FE8FFCFEA0FFFE9DFEFE8B
        FBFE72F3FE55E8FE34DDFE15D2FE0CC7F50ABBEA07AFE0029ED10EADDB49E7FF
        6BF0FE8DFBFEB5FFFED8FFFFD3FFFFACFFFE85F9FE64EDFE41E2FE1CD6FE0DCA
        F80ABEED07B2E2029FD20AA6D64DE6FF73F3FE99FEFED1FFFFFFFFFFFAFFFFC3
        FFFE8FFCFE6BF0FE46E4FE21D7FE0DCBF90BBFEE07B3E3019DD0029ACE41DAF7
        71F4FF94FDFEC5FFFEEFFFFFE9FFFFB9FFFE8BFBFE68EFFE44E3FE1FD6FE0DCB
        F90BBFEE07B0E1009ACDFF00FF1EB9E167F2FF82F8FE9FFFFEB6FFFEB3FFFE98
        FEFE7BF6FE5CEBFE3AE0FE18D4FE0CC8F70BBEED04A7D8FF00FFFF00FF0299CC
        3CD2F16EF4FF7DF6FE88FAFE86FAFE79F5FE64EEFE49E5FE29DAFE10D0FC0CC6
        F508B4E3019ACDFF00FFFF00FFFF00FF059DCF3AD2F15FEFFF65F0FF63EDFE58
        EAFE47E4FE30DDFE16D4FF0ECCF909B7E7019CCFFF00FFFF00FFFF00FFFF00FF
        FF00FF0099CC1CB8E137D7F63EE1FE36E0FF27DBFF15D3FE0CC5F306ADDE0099
        CCFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF009ACD07A5D508
        ABDB05AADB02A3D6019BCEFF00FFFF00FFFF00FFFF00FFFF00FF}
      TabOrder = 2
      OnClick = btnSkipClick
    end
    object btnRunToMark: TBitBtn
      Left = 175
      Top = 6
      Width = 113
      Height = 33
      Anchors = [akTop, akRight]
      Caption = 'Run to Mark (F5)'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000130B0000130B00000000000000000001FF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FF76372D76372DAF67228D4C28FF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF76372D
        AB6626B87D2BAF67228D3819FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFA65B33AF6A2DAB6626A35610A75A20C2978FFF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF8D4C28
        A65B3392360DA65C28EAD8C5FCF8FAD6BCBBFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FF7B2C1D9D482CE8D4CDFFFFFFFEFDFDFA
        F3F4D3B9B8FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFB08784FFFBFEFCF9F9FFFFFFFFFFFFD7C6C6602A2BFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFB8999AFDF5F6FFFFFF9E
        7E7DB19595C7B2B2602A2BFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FFB8999BBBA1A2C4AEAE693535BFA9A9BCA3A3602A2BFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF5E262693
        6D6DCFBDBD714140C4B0B2BBA1A0894022863723FF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FF5D2626987373C6B2B4744543BB86599A46
        18894022FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FF5C2729997371AD6E4AA65B1AB3743C92481E894022FF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF8637239A4218AF6D45B271
        39A45C19964E1F863F24FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FF863723943B1E9B46239B4816A75B199F5A1E944C20FF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF8F3218953D
        199E4C199D541DFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FFFF00FF903419963F19FF00FFFF00FF}
      TabOrder = 3
      OnClick = btnRunToMarkClick
    end
    object btnClearMarks: TBitBtn
      Left = 7
      Top = 6
      Width = 113
      Height = 33
      Caption = 'Clear Marks'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
        FF00FFFF00FFB3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3B3
        B3B3B3B3B3B3B3B3B3B3FF00FFFF00FFFF00FFFF00FFB3B3B3FCFCFCFCFCFCFC
        FCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCB3B3B3FF00FFFF00FF
        FF00FFFF00FFB3B3B3FCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFCFC
        FCFCFCFCFCFCFCB3B3B3FF00FFFF00FFFF00FFFF00FFB3B3B3FAFAFAFAFAFAFA
        FAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAFAB3B3B3FF00FFFF00FF
        FF00FFFF00FFB3B3B3F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8
        F8F8F8F8F8F8F8B3B3B3FF00FFFF00FFFF00FFFF00FFB3B3B3F6F6F6F6F6F6F6
        F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6F6B3B3B3FF00FFFF00FF
        FF00FFFF00FFB3B3B3F4F4F4F4F4F4F4F4F4F4F4F4F4F4F4F4F4F4F4F4F4F4F4
        F4F4F4F4F4F4F4B3B3B3FF00FFFF00FFFF00FFFF00FFB3B3B3F2F2F2F2F2F2F2
        F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2F2B3B3B3FF00FFFF00FF
        FF00FFFF00FFB3B3B3F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0
        F0F0F0F0F0F0F0B3B3B3FF00FFFF00FFFF00FFFF00FFB3B3B3EEEEEEEEEEEEEE
        EEEEEEEEEEEEEEEEEEEEEED1D1D1D1D1D1D1D1D1D1D1D1B3B3B3FF00FFFF00FF
        FF00FFFF00FFB3B3B3ECECECECECECECECECECECECECECECECECECBBBBBBBBBB
        BBBABABAB9B9B9B3B3B3FF00FFFF00FFFF00FFFF00FFB3B3B3EAEAEAEAEAEAEA
        EAEAEAEAEAEAEAEAEAEAEAAEAEAEAEAEAEAEAEAEAEAEAEB3B3B3FF00FFFF00FF
        FF00FFFF00FFB3B3B3E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8BFBFBFF7F7F7F7F7
        F7DDDDDDB3B3B3FF00FFFF00FFFF00FFFF00FFFF00FFB3B3B3E5E5E5E5E5E5E5
        E5E5E5E5E5E5E5E5BFBFBFF7F7F7D2D2D2B3B3B3FF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFB3B3B3E4E4E4E4E4E4E4E4E4E4E4E4E4E4E4BFBFBFD2D2D2B3B3
        B3FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFB3B3B3B3B3B3B3B3B3B3
        B3B3B3B3B3B3B3B3B3B3B3B3B3B3FF00FFFF00FFFF00FFFF00FF}
      TabOrder = 4
      OnClick = btnClearMarksClick
    end
    object btnFinish: TBitBtn
      Left = 532
      Top = 6
      Width = 113
      Height = 33
      Anchors = [akTop, akRight]
      Caption = 'Finish (F9)'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000130B0000130B00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF317A362D7532FF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFF39854037833D317B372E7633FFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF429249408E4754A35C4F9F5732
        7C382E7734FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        4B9E53499A515BAC6477CA8274C87E51A059337D392F7835FFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFF53A95C51A65A63B56D7ECE897BCC8776CA8176
        C98152A25A347E3A307935FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5AB46559B063
        6BBD7684D2907AC98560B26A63B46D78C98378CB8253A35C347F3A317A36FFFF
        FFFFFFFFFFFFFFFFFFFF5EB9695BB56679C98680CE8D51A65A4DA156499C515C
        AD677CCC8679CB8554A45D35803B317B37FFFFFFFFFFFFFFFFFFFFFFFF5FBA6A
        5CB6666DC07955AC5FFFFFFFFFFFFF4A9D525EAE687DCD897CCD8756A55F3681
        3C327C38FFFFFFFFFFFFFFFFFFFFFFFF5FBB6A5CB767FFFFFFFFFFFFFFFFFFFF
        FFFF4B9E535FAF697FCE8A7ECE8957A66037823D337D39FFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4B9F5460B06A81CF8D7FCF
        8B58A761398540347E3AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFF4CA05562B26C82D18F7AC88557A66038843FFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4DA15663B3
        6D5FAF69419149FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFF4EA2574A9D52FFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      TabOrder = 5
      OnClick = btnFinishClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 772
    Height = 67
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object mSource: TMemo
      Left = 0
      Top = 0
      Width = 772
      Height = 67
      Align = alClient
      HideSelection = False
      ReadOnly = True
      TabOrder = 0
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 70
    Width = 772
    Height = 380
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object Splitter2: TSplitter
      Left = 211
      Top = 0
      Height = 380
      OnMoved = Splitter2Moved
      ExplicitLeft = 482
      ExplicitTop = 208
      ExplicitHeight = 100
    end
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 211
      Height = 380
      Align = alLeft
      BevelOuter = bvNone
      BevelWidth = 4
      BorderWidth = 4
      TabOrder = 0
      object vtExpressions: TVirtualStringTree
        Left = 4
        Top = 23
        Width = 203
        Height = 353
        Align = alClient
        Header.AutoSizeIndex = 0
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'Tahoma'
        Header.Font.Style = []
        Header.MainColumn = -1
        Images = ImageList1
        NodeDataSize = 4
        TabOrder = 0
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
        TreeOptions.SelectionOptions = [toFullRowSelect]
        OnChecked = vtExpressionsChecked
        OnGetText = vtExpressionsGetText
        OnGetImageIndex = vtExpressionsGetImageIndex
        OnInitChildren = vtExpressionsInitChildren
        OnInitNode = vtExpressionsInitNode
        Columns = <>
      end
      object Panel5: TPanel
        Left = 4
        Top = 4
        Width = 203
        Height = 19
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = ' Break Point Marks'
        TabOrder = 1
      end
    end
    object PageControl1: TPageControl
      Left = 214
      Top = 0
      Width = 558
      Height = 380
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 1
      OnChange = PageControl1Change
      object TabSheet1: TTabSheet
        Caption = 'Resource'
        object mResource: TMemo
          Left = 0
          Top = 0
          Width = 550
          Height = 352
          Align = alClient
          TabOrder = 0
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Context'
        ImageIndex = 1
        object mContext: TMemo
          Left = 0
          Top = 0
          Width = 550
          Height = 352
          Align = alClient
          TabOrder = 0
        end
      end
      object TabSheet3: TTabSheet
        Caption = 'Input'
        ImageIndex = 2
        object mInput: TMemo
          Left = 0
          Top = 0
          Width = 550
          Height = 352
          Align = alClient
          TabOrder = 0
        end
      end
      object TabSheet4: TTabSheet
        Caption = 'Input 2'
        ImageIndex = 3
        object mInput2: TMemo
          Left = 0
          Top = 0
          Width = 550
          Height = 352
          Align = alClient
          TabOrder = 0
        end
      end
      object TabSheet5: TTabSheet
        Caption = 'Outcome'
        ImageIndex = 4
        object mOutcome: TMemo
          Left = 0
          Top = 0
          Width = 550
          Height = 352
          Align = alClient
          TabOrder = 0
        end
      end
      object TabSheet6: TTabSheet
        Caption = 'Console'
        ImageIndex = 5
        object mConsole: TMemo
          Left = 0
          Top = 0
          Width = 550
          Height = 352
          Align = alClient
          TabOrder = 0
          WordWrap = False
        end
      end
    end
  end
  object ImageList1: TImageList
    Left = 12
    Top = 104
    Bitmap = {
      494C010103000C00240010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000CD1C0000CDAA0000CDC60000CDFF0000CDC60000CDAA0000
      CD1C000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000CD710000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CD710000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      CD710000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CDFF0000CD7100000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000CD1C0000
      CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CDFF0000CDFF0000CD1C000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008D8D8D388D8D8DC68D8D8DFF8D8D8DC68D8D8D380000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000025940038259400C6259400FF259400C6259400380000
      00000000000000000000000000000000000000000000000000000000CDAA0000
      CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CDFF0000CDFF0000CDAA000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008D8D8D388D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D
      8D38000000000000000000000000000000000000000000000000000000000000
      00000000000025940038259400FF259400FF259400FF259400FF259400FF2594
      00380000000000000000000000000000000000000000000000000000CDC60000
      CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CDFF0000CDFF0000CDC6000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008D8D8DC68D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D
      8DC6000000000000000000000000000000000000000000000000000000000000
      000000000000259400C6259400FF259400FF259400FF259400FF259400FF2594
      00C60000000000000000000000000000000000000000000000000000CDFF0000
      CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CDFF0000CDFF0000CDFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D
      8DFF000000000000000000000000000000000000000000000000000000000000
      000000000000259400FF259400FF259400FF259400FF259400FF259400FF2594
      00FF0000000000000000000000000000000000000000000000000000CDC60000
      CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CDFF0000CDFF0000CDC6000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008D8D8DC68D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D
      8DC6000000000000000000000000000000000000000000000000000000000000
      000000000000259400C6259400FF259400FF259400FF259400FF259400FF2594
      00C60000000000000000000000000000000000000000000000000000CDAA0000
      CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CDFF0000CDFF0000CDAA000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008D8D8D388D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D8DFF8D8D
      8D38000000000000000000000000000000000000000000000000000000000000
      00000000000025940038259400FF259400FF259400FF259400FF259400FF2594
      00380000000000000000000000000000000000000000000000000000CD1C0000
      CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CDFF0000CDFF0000CD1C000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008D8D8D388D8D8DC68D8D8DFF8D8D8DC68D8D8D380000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000025940038259400C6259400FF259400C6259400380000
      0000000000000000000000000000000000000000000000000000000000000000
      CD710000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CDFF0000CD7100000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000CD710000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000CDFF0000
      CDFF0000CD710000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000CD1C0000CDAA0000CDC60000CDFF0000CDC60000CDAA0000
      CD1C000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFFFFFF0000FFFFFFFFF80F0000
      FFFFFFFFF0070000FFFFFFFFE0030000FFFFFFFFC0010000FC1FFC1FC0010000
      F80FF80FC0010000F80FF80FC0010000F80FF80FC0010000F80FF80FC0010000
      F80FF80FC0010000FC1FFC1FE0030000FFFFFFFFF0070000FFFFFFFFF80F0000
      FFFFFFFFFFFF0000FFFFFFFFFFFF000000000000000000000000000000000000
      000000000000}
  end
end

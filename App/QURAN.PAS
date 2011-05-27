unit Quran;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ApUtils, ExtCtrls, EPGfxCmp, StdCtrls, BmpRes, RXSpin,
  StColl, SpeedBar, RXCtrls, StStrS, StrHlder, StStrZ, Arabic, SoundsMg;

type
  TQuranForm = class(TForm)
    pnlMasterContainer: TPanel;
    barSuraControl: TSpeedBar;
    btnModuleStop: TRxSpeedButton;
    imgPageBorder: TImage;
    lblSuraName: TLabel;
    barSura: TSpeedBar;
    pnlInfoCenter: TPanel;
    lblSelectedWordTranslation: TLabel;
    bvlSelectedWord: TBevel;
    lblSelectedWord: TLabel;
    bvlSelectedAyah: TBevel;
    lblAyahMeaning: TLabel;
    lblAyahMeaningText: TLabel;
    lblAyahNumber: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SuraButtonClick(Sender: TObject);
    procedure btnModuleStopClick(Sender: TObject);
    procedure ArabicWordMouseEnter(Sender: TObject);
    procedure ArabicWordClick(Sender: TObject);
    procedure ArabicWordMouseExit(Sender: TObject);
    procedure pnlMasterContainerDblClick(Sender: TObject);
    procedure lblSuraNameClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FSura : TSura;
    FShowOutlines : Boolean;

    procedure ClearTranslations;
    procedure LoadSuraInfo(ASura : TSura);
    procedure SetSura(ASura : Integer);
  public
    property Sura : Integer write SetSura;
  end;

implementation

{$R *.DFM}

uses VCLUtils, Main;

procedure TQuranForm.FormCreate(Sender: TObject);

  procedure CreateSuraButtons;
  const
    nTopButtonY = 60;
  var
    nSuraIdx : Integer;
    Btn : TRxSpeedButton;
    Sura : TSura;
  begin
    if MainForm.Suras.Count <= 0 then
      Exit;

    for nSuraIdx := 0 to MainForm.Suras.Count-1 do begin
      Sura := TSura(MainForm.Suras[nSuraIdx]);
      Btn := TRxSpeedButton.Create(Self);
      Btn.Parent := barSuraControl;
      Btn.Name := 'siSura'+IntToStr(Sura.Number);
      Btn.Top := nTopButtonY + (barSuraControl.BtnHeight * nSuraIdx);
      Btn.Visible := True;
      Btn.GroupIndex := 1;
      Btn.Caption := Sura.Name;
      Btn.Flat := True;
      Btn.Transparent := True;
      Btn.Tag := Sura.Number;
      Btn.OnClick := SuraButtonClick;
      Btn.Width := barSuraControl.BtnWidth;
    end;
  end;

begin
  MakeFullScreen(Self, pnlMasterContainer);

  CreateSuraButtons;
  Sura := 1;
end;

procedure TQuranForm.LoadSuraInfo(ASura : TSura);

  procedure CreateWordButtons;
  var
    nIdx : Integer;
    WordButton : TRxSpeedButton;
    WordData : TSuraWord;
  begin
    if FSura.Words.Count <= 0 then
      Exit;

    for nIdx := 0 to FSura.Words.Count-1 do begin
      WordData := TSuraWord(FSura.Words[nIdx]);
      WordButton := TRxSpeedButton.Create(Self);
      WordButton.Parent := barSura;

      if FShowOutlines then begin
        WordButton.Flat := False;
        WordButton.Font.Style := [fsBold];
        WordButton.Font.Color := clBlue;
        WordButton.Caption := IntToStr(nIdx);
      end else
        WordButton.Flat := True;

      WordButton.Transparent := True;
      WordButton.Style := rbfOutline;
      WordButton.SetBounds(WordData.BmpArea.Left, WordData.BmpArea.Top,
                           WordData.BmpArea.Right-WordData.BmpArea.Left,
                           WordData.BmpArea.Bottom-WordData.BmpArea.Top);
      WordButton.Tag := LongInt(WordData);
      WordButton.OnMouseEnter := ArabicWordMouseEnter;
      WordButton.OnClick := ArabicWordClick;
      WordButton.OnMouseLeave := ArabicWordMouseExit;
    end;
  end;

var
  strResId : String;
  Bitmap : TBitmap;
begin
  ClearControls(barSura);

  if ASura = Nil then begin
    barSura.Wallpaper := Nil;
    Exit;
  end;

  strResId := ASura.BitmapResId;
  Bitmap := LoadBitmapResource(MainForm.ResDLLInstance, StringToPChar(strResId));
  barSura.Wallpaper.Bitmap := Bitmap;
  barSura.Height := Bitmap.Height;
  Bitmap.Free;

  CreateWordButtons;
end;

procedure TQuranForm.SetSura(ASura : Integer);
var
  SB : TRxSpeedButton;
begin
  SB := PushTaggedSpdBtnDown(barSuraControl, ASura);
  if SB <> Nil then
    lblSuraName.Caption := SB.Caption;
  FSura := MainForm.Suras.Suras[ASura];
  LoadSuraInfo(FSura);
  ClearTranslations;
end;

procedure TQuranForm.SuraButtonClick(Sender: TObject);
begin
  MainForm.PlayFmtSound('QS%d', [(Sender as TRxSpeedButton).Tag], True, Nil);
  Sura := (Sender as TRxSpeedButton).Tag;
end;

procedure TQuranForm.btnModuleStopClick(Sender: TObject);
begin
  Close;
end;

procedure TQuranForm.ClearTranslations;
begin
  lblSelectedWordTranslation.Caption := '';
  lblAyahMeaningText.Caption := '';
  lblAyahNumber.Caption := '';
end;

procedure TQuranForm.ArabicWordMouseEnter(Sender: TObject);
var
  B : TRxSpeedButton;
  WordData : TSuraWord;
  strAyah, strWord : String;
begin
  MainForm.ResSounds.PlaySound('IDW_TINK', spmAsync);
  B := Sender as TRxSpeedButton;
  WordData := TSuraWord(B.Tag);

  if WordData.AyahNum-1 < FSura.AyahMeanings.Count then
    strAyah := FSura.AyahMeanings[WordData.AyahNum-1]
  else
    strAyah := IntToStr(WordData.AyahNum) + ' of ' + IntToStr(FSura.AyahMeanings.Count);

  lblAyahNumber.Caption := '['+IntToStr(WordData.AyahNum)+']'; 
  if lblAyahMeaningText.Caption <> strAyah then
    lblAyahMeaningText.Caption := strAyah;

  { is this an ayah number button? if not, display word's translation }
  if WordData.WordNum > -1 then begin
    if WordData.AyahNum-1 < FSura.WordTranslations.Count then
      strWord := ExtractWordS(WordData.WordNum, FSura.WordTranslations[WordData.AyahNum-1], ':')
    else
      strWord := IntToStr(WordData.WordNum) + ' of ' + IntToStr(FSura.WordTranslations.Count);
    lblSelectedWordTranslation.Caption := strWord;
  end else
    lblSelectedWordTranslation.Caption := '';
end;

procedure TQuranForm.ArabicWordClick(Sender: TObject);
var
  B : TRxSpeedButton;
  WordData : TSuraWord;
begin
  B := Sender as TRxSpeedButton;
  WordData := TSuraWord(B.Tag);

  if WordData.WordNum = -1 then
    MainForm.PlayFmtSound('QA%.3d.%.3d', [WordData.SuraNum, WordData.AyahNum], True, Nil)
  else
    MainForm.PlayFmtSound('QW%.3d.%.3d.%.2d', [WordData.SuraNum, WordData.AyahNum, WordData.WordNum], True, Nil);
end;

procedure TQuranForm.ArabicWordMouseExit(Sender: TObject);
begin
  lblSelectedWordTranslation.Caption := '';
end;

procedure TQuranForm.pnlMasterContainerDblClick(Sender: TObject);
begin
  FShowOutlines := not FShowOutlines;
  Sura := FSura.Number;
end;

procedure TQuranForm.lblSuraNameClick(Sender: TObject);
begin
  if FSura <> Nil then begin
    MainForm.PlaySoundFile('AOOZO', False, Nil);
    MainForm.PlaySoundFile('BISMI', False, Nil);
    MainForm.PlayFmtSound('QSR%.3d', [FSura.Number], True, Nil)
  end;
end;

procedure TQuranForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainForm.StopAllSounds;
end;

end.

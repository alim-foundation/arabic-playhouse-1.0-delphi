unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ApUtils, RXCtrls, SpeedBar, EPGfxCmp, ExtCtrls, MPlayer,
  SoundsMg, StrHlder, Arabic, StdCtrls, StDict, EnhHint, AppEvent, Menus;

type
  TMainForm = class(TForm)
    pnlMasterContainer: TPanel;
    pnlWorkArea: TPanel;
    imgAppName: TEPImage;
    MediaPlayer: TMediaPlayer;
    btnModulePrayers: TRxSpeedButton;
    barModuleButtons: TSpeedBar;
    btnModuleShapes: TRxSpeedButton;
    btnModuleSounds: TRxSpeedButton;
    btnModuleLetters: TRxSpeedButton;
    btnModuleConnect: TRxSpeedButton;
    btnModuleQuran: TRxSpeedButton;
    btnAppClose: TRxSpeedButton;
    btnModuleConnectSounds: TRxSpeedButton;
    lblAppVersion: TLabel;
    btnOptions: TRxSpeedButton;
    EnhHints: TEnhHint;
    sthAppDataFile: TStrHolder;
    sthSndMapDataFile: TStrHolder;
    pmOptionsPopup: TPopupMenu;
    pmiBalloonHelp: TMenuItem;
    pmiMusic: TMenuItem;
    N1: TMenuItem;
    pmiMalePersonality: TMenuItem;
    pmiFemalePersonality: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ModuleButtonClick(Sender: TObject);
    procedure btnAppCloseClick(Sender: TObject);
    procedure btnModuleShapesMouseEnter(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure imgAppNameClick(Sender: TObject);
    procedure OnMessage(var Msg: TMsg; var Handled: Boolean);
    procedure PersonalityMenuClick(Sender: TObject);
    procedure pmiBalloonHelpClick(Sender: TObject);
    procedure pmiMusicClick(Sender: TObject);
    procedure MuduleButtonRightClick(Sender: TObject);
  protected
    FResSounds : TResSoundsManager;
    FWordsSets : array[TWordsClass] of TArabicWordsSetList;
    FSuras : TSurasList;
    FSmallPrayers : TSmallPrayers;
    FSimilarSounds : TSimilarSounds;
    FSoundsMap : TStDictionary;
    FDataFileName : String;
    FSndMapFileName : String;
    FHaveExternalData : Boolean;
    FHaveExternalSndMapData : Boolean;
    FResDLLInstance : THandle;
    FPersonality : TPersonality;
    FShowOneHint : Boolean;

    function GetWordsSet(Index : TWordsClass) : TArabicWordsSetList;
    function GetPersonalityId : Integer;
    procedure ChangeModule(AModule : TAppModule);
    procedure HandleAppModuleMsg(var Msg : TMessage); message CM_APPMODULE;
    procedure SetModule(AModule : TAppModule);
    procedure SetPersonality(APersonality : TPersonality);
    procedure OnShowHint(var HintStr: string; var CanShow: Boolean;
                         var HintInfo: THintInfo);
  public
    procedure PlaySoundFile(strSoundFile : String;
                            bAsynch : Boolean;
                            pfnNotifyProc : TNotifyEvent);
    procedure PlayFmtSound(strSndFmt : String;
                           rvArgs : array of const;
                           bAsynch : Boolean;
                           pfnNotifyProc : TNotifyEvent);
    procedure StopAllSounds;
    procedure PlayButtonEnterSound(Sender : TObject);
    procedure ShowOneHintOnRightClick(Sender: TObject);

    property Module : TAppModule write SetModule;
    property ResSounds : TResSoundsManager read FResSounds;
    property WordsSets[Index : TWordsClass] : TArabicWordsSetList read GetWordsSet;
    property Suras : TSurasList read FSuras;
    property Prayers : TSmallPrayers read FSmallPrayers;
    property SimilarSounds : TSimilarSounds read FSimilarSounds;

    property DataFileName : String read FDataFileName;
    property HaveExternalData : Boolean read FHaveExternalData;
    property ResDLLInstance : THandle read FResDLLInstance;

    property Personality : TPersonality read FPersonality write SetPersonality;
    property PersonalityId : Integer read GetPersonalityId;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

uses Words, Quran, StStrS, Prayers, About, VCLUtils, MMSystem, ErrorFrm, IniFiles;

procedure TMainForm.FormCreate(Sender: TObject);
const
  strResourceDLLName = 'APLAYRES.DLL';
  rstrSetNames : array[TWordsClass] of String =
                 ('ConnectSounds', 'WordsClass 1', 'WordsClass 2', 'WordsClass 3', 'WordsClass 4');
var
  nColorDepth, nSndIdx : Integer;
  eClass : TWordsClass;
  strKey : String;
  pstrData : Pointer;
  strDllPath : String;
  Ini : TIniFile;
begin
  Screen.Cursors[crHand] := LoadCursor(ResDLLInstance, IDC_HANDCURSOR);

  try
    strDllPath := ForcePath(dtApplication, strResourceDLLName);
    FResDLLInstance := LoadDLL(strDllPath);
  except
    MessageDlg('An important application file '+strDllPath+' was not found. You should call ISL Tech Support.',
               mtError, [mbOk], 0);
    Application.Terminate;
    Exit;
  end;

  nColorDepth := GetDeviceCaps(Canvas.Handle, BitsPixel);
  if nColorDepth < 8 then begin
    if MessageDlg('Your graphics card is set to '+IntToStr(nColorDepth)+' bit color. It should be '+
                  'set to display 256 or more colors (8-bit or better). Run Arabic Playhouse anyway?',
                  mtConfirmation, [mbYes, mbNo], 0) = mrNo then begin
      Exit;
    end;
  end;

  MakeFullScreen(Self, pnlMasterContainer);

  Ini := TIniFile.Create('WIN.INI');
  Personality := TPersonality(Ini.ReadInteger('APLAY', 'Personality', 0));
  pmiMusic.Checked := Ini.ReadBool('APLAY', 'Music', True);
  Ini.Free;

  for eClass := Low(TWordsClass) to High(TWordsClass) do
    FWordsSets[eClass] := TArabicWordsSetList.Create;
  FSuras := TSurasList.Create;
  FSmallPrayers := TSmallPrayers.Create;
  FSimilarSounds := TSimilarSounds.Create;

  FDataFileName := ForceExtensionS(Application.ExeName, 'APD');
  FSndMapFileName := ForceExtensionS(Application.ExeName, 'SMD');

  FHaveExternalData := FileExists(FDataFileName);
  FHaveExternalSndMapData := FileExists(FSndMapFileName);

  if FHaveExternalData then
    sthAppDataFile.Strings.LoadFromFile(FDataFileName);

  if FHaveExternalSndMapData then
    sthSndMapDataFile.Strings.LoadFromFile(FSndMapFileName);

  for eClass := Low(TWordsClass) to High(TWordsClass) do
    FWordsSets[eClass].LoadSetsFromStrings(sthAppDataFile.Strings, rstrSetNames[eClass]);

  FSuras.LoadFromStrings(sthAppDataFile.Strings);
  FSmallPrayers.LoadFromStrings(sthAppDataFile.Strings);
  FSimilarSounds.LoadFromStrings(sthAppDataFile.Strings);

  FResSounds := TResSoundsManager.Create;
  FResSounds.ResInstance := FResDLLInstance;
  FResSounds.AddSoundResource('IDW_BUTTON');
  FResSounds.AddSoundResource('IDW_ITEM');
  FResSounds.AddSoundResource('IDW_CLICK');
  FResSounds.AddSoundResource('IDW_PAGE');
  FResSounds.AddSoundResource('IDW_TICK');
  FResSounds.AddSoundResource('IDW_TINK');
  FResSounds.AddSoundResource('IDW_TINK2');
  FResSounds.AddSoundResource('IDW_TINK3');
  FResSounds.AddSoundResource('IDW_BELL');
  FResSounds.AddSoundResource('IDW_PHASER');
  FResSounds.AddSoundResource('IDW_THUD');
  FResSounds.AddSoundResource('IDW_WHOOSH');
  FResSounds.AddSoundResource('IDW_TYPE');

  FSoundsMap := TStDictionary.Create(sthSndMapDataFile.Strings.Count);
  if sthSndMapDataFile.Strings.Count > 0 then
    for nSndIdx := 0 to sthSndMapDataFile.Strings.Count -1 do begin
      if Pos('=', sthSndMapDataFile.Strings[nSndIdx]) = 0 then
        continue;

      strKey := TrimS(ExtractWordS(1, sthSndMapDataFile.Strings[nSndIdx], '='));

      if not FSoundsMap.Exists(strKey, pstrData) then
        FSoundsMap.Add(strKey, Pointer(nSndIdx));
    end;

  if pmiMusic.Checked then
    PlaySoundFile('INTRO', True, Nil);
  Application.OnShowHint := OnShowHint;
  Application.OnMessage := OnMessage;
  TRxSpeedButton.SetDefaultMouseEnterHdl(PlayButtonEnterSound);
  TRxSpeedButton.SetDefaultRightClickHdl(ShowOneHintOnRightClick);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  eClass : TWordsClass;
  Ini : TIniFile;
begin
  Ini := TIniFile.Create('WIN.INI');
  Ini.WriteInteger('APLAY', 'Personality', PersonalityId);
  Ini.WriteBool('APLAY', 'Music', pmiMusic.Checked);
  Ini.Free;

  for eClass := Low(TWordsClass) to High(TWordsClass) do
    FWordsSets[eClass].Free;
  FSuras.Free;
  FSmallPrayers.Free;
  FSimilarSounds.Free;
  FResSounds.Free;
  FSoundsMap.Free;
  FreeLibrary(FResDLLInstance);
end;

procedure TMainForm.ModuleButtonClick(Sender: TObject);
begin
  if Sender is TRxSpeedButton then
    Module := TAppModule((Sender as TRxSpeedButton).Tag);
end;

procedure TMainForm.ChangeModule(AModule : TAppModule);
var
  SmallPrayersForm : TSmallPrayersForm;
  WordsForm : TWordsForm;
  QuranForm : TQuranForm;
begin
  if pmiMusic.Checked then
    PlayFmtSound('MTS%d', [Ord(AModule)], True, Nil);
  case AModule of
    amLetters,
    amSounds,
    amShapes,
    amConnectSounds,
    amConnect :
      begin
        Application.CreateForm(TWordsForm, WordsForm);
        case AModule of
          amLetters : WordsForm.Module := wmLetters;
          amSounds  : WordsForm.Module := wmSounds;
          amShapes  : WordsForm.Module := wmShapes;
          amConnectSounds : WordsForm.Module := wmConnectSounds;
          amConnect : WordsForm.Module := wmConnect;
        end;
        WordsForm.ShowModal;
        WordsForm.Free;
      end;
    amQuran :
      begin
        Application.CreateForm(TQuranForm, QuranForm);
        QuranForm.ShowModal;
        QuranForm.Free;
      end;
    amSmallPrayers :
      begin
        Application.CreateForm(TSmallPrayersForm, SmallPrayersForm);
        SmallPrayersForm.ShowModal;
        SmallPrayersForm.Free;
      end;
  end;
end;

procedure TMainForm.HandleAppModuleMsg(var Msg : TMessage);
begin
  case Msg.wParam of
    MP_CHANGEMODULE : ChangeModule(TAppModule(Msg.lParam));
  end;
end;

function TMainForm.GetPersonalityId : Integer;
begin
  Result := Ord(Personality);
end;

procedure TMainForm.SetPersonality(APersonality : TPersonality);
begin
  FPersonality := APersonality;
  pmiMalePersonality.Checked := APersonality = prMale;
  pmiFemalePersonality.Checked := APersonality = prFemale;
end;

function TMainForm.GetWordsSet(Index : TWordsClass) : TArabicWordsSetList;
begin
  Result := FWordsSets[Index];
end;

procedure TMainForm.SetModule(AModule : TAppModule);
begin
  PostMessage(Handle, CM_APPMODULE, MP_CHANGEMODULE, LongInt(Ord(AModule)));
end;

procedure TMainForm.btnAppCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.StopAllSounds;
begin
  SndPlaySound(Nil, 0);
  if MediaPlayer.Mode = mpPlaying then
    MediaPlayer.Stop;
end;

procedure TMainForm.PlaySoundFile(strSoundFile : String; bAsynch : Boolean;
                                  pfnNotifyProc : TNotifyEvent);
var
  pData : Pointer;
  nSndMapIdx : LongInt;
  strFileInfo, strPos : String;
  lStartPos, lEndPos : LongInt;
begin
  { first see if the sound file is referring to a known sound key }
  if FSoundsMap.Exists(strSoundFile, pData) then begin
    nSndMapIdx := LongInt(pData);
    strFileInfo := TrimS(ExtractWordS(2, sthSndMapDataFile.Strings[nSndMapIdx], '='));
    if Pos('@', strFileInfo) > 0 then begin
      strSoundFile := ExtractWordS(1, strFileInfo, '@');
      strPos := ExtractWordS(2, strFileInfo, '@');
      lStartPos := StrToIntDef(ExtractWordS(1, strPos, '-'), -1);
      lEndPos := StrToIntDef(ExtractWordS(2, strPos, '-'), -1);
    end else begin
      lStartPos := -1;
      lEndPos := -1;
      strSoundFile := strFileInfo;
    end;
  end;

  if Pos('\', strSoundFile) = 0 then
    strSoundFile := ForcePath(dtApplication, strSoundFile);

  if not FileExists(strSoundFile) and (not RunningOffCD) then begin
    AppError(aeMediaFileNotFound, [strSoundFile]);
    Exit;
  end;

  StopAllSounds;
  MediaPlayer.Filename := strSoundFile;
  MediaPlayer.Open;

  if Assigned(pfnNotifyProc) then begin
    MediaPlayer.OnNotify := pfnNotifyProc;
    MediaPlayer.Notify := True;
  end else begin
    MediaPlayer.OnNotify := Nil;
    MediaPlayer.Notify := False;
  end;

  MediaPlayer.Wait := not bAsynch;

  if((lStartPos <> -1) and (lEndPos > lStartPos)) then begin
    MediaPlayer.TimeFormat := tfMilliseconds;
    MediaPlayer.StartPos := lStartPos;
    MediaPlayer.EndPos := lEndPos;
  end else if((lStartPos = -1) and (lEndPos > 0)) then begin
    MediaPlayer.TimeFormat := tfMilliseconds;
    MediaPlayer.StartPos := MediaPlayer.Start;
    MediaPlayer.EndPos := lEndPos;
  end else if((lStartPos <> -1) and (lEndPos = -1)) then begin
    MediaPlayer.TimeFormat := tfMilliseconds;
    MediaPlayer.StartPos := lStartPos;
    MediaPlayer.EndPos := MediaPlayer.Length;
  end;

  MediaPlayer.Play;
end;

procedure TMainForm.PlayFmtSound(strSndFmt : String;
                                 rvArgs : array of const;
                                 bAsynch : Boolean;
                                 pfnNotifyProc : TNotifyEvent);
var
  strKey : String;
begin
  FmtStr(strKey, strSndFmt, rvArgs);
  PlaySoundFile(strKey, bAsynch, pfnNotifyProc);
end;

procedure TMainForm.PlayButtonEnterSound(Sender : TObject);
begin
  MainForm.ResSounds.PlaySound('IDW_BUTTON', spmAsync);
end;

procedure TMainForm.btnModuleShapesMouseEnter(Sender: TObject);
begin
  ResSounds.PlaySound('IDW_ITEM', spmAsync);
end;

procedure TMainForm.imgAppNameClick(Sender: TObject);
var
  AboutBox : TAboutBox;
begin
  Application.CreateForm(TAboutBox, AboutBox);
  AboutBox.ShowModal;
  AboutBox.Free;
end;

procedure TMainForm.ShowOneHintOnRightClick(Sender: TObject);
begin
  FShowOneHint := True;
end;

procedure TMainForm.OnShowHint(var HintStr: string; var CanShow: Boolean;
                               var HintInfo: THintInfo);
begin
  CanShow := pmiBalloonHelp.Checked or FShowOneHint;

  if FShowOneHint and (HintStr <> '') then
    ResSounds.PlaySound('IDW_WHOOSH', spmAsync);

  if FShowOneHint then
    FShowOneHint := False;
  HintInfo.HintMaxWidth := 225;
end;

procedure TMainForm.OnMessage(var Msg: TMsg; var Handled: Boolean);
begin
  Handled := False;
  if (Msg.Message <> WM_KEYUP) then
    Exit;

  if (Msg.wParam = VK_SHIFT) or (Msg.wParam = VK_CONTROL) then
    FShowOneHint := True;

  if (Msg.wParam = VK_ESCAPE) then begin
    Handled := True;
    StopAllSounds;
  end;
end;

procedure TMainForm.PersonalityMenuClick(Sender: TObject);
begin
  if Sender = pmiMalePersonality then
    Personality := prMale
  else
    Personality := prFemale;
end;

procedure TMainForm.pmiBalloonHelpClick(Sender: TObject);
begin
  pmiBalloonHelp.Checked := not pmiBalloonHelp.Checked;
end;

procedure TMainForm.pmiMusicClick(Sender: TObject);
begin
  pmiMusic.Checked := not pmiMusic.Checked;
end;

procedure TMainForm.MuduleButtonRightClick(Sender: TObject);
begin
  FShowOneHint := True;
  PlayFmtSound('MDS%d.%d', [PersonalityId, (Sender as TRxSpeedButton).Tag], True, Nil);
end;

end.

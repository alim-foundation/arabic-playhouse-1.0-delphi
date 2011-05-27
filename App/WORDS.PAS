unit Words;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, SpeedBar, ExtCtrls, RXCtrls, EPGfxCmp, ApUtils, Arabic,
  StBase, StColl, MPlayer, StBits, SevenChr, StdCtrls, RXSpin, Tabs,
  StrHlder, StStrS, StUtils;

type
  TQuizControl = class;
  TQuizPhase = (qpEnd, qpStart, qpQuizzing, qpRequestStop);
  TQuizResetMode = (rmAll, rmWrongAnswerData);
  TQuizQuestionType = TControl;
  TQuizControl = class(TObject)
  protected
    FMsgHandlerHwnd : THandle;
    FQuizItemsParent : TWinControl;
    FQuizPhase : TQuizPhase;
    FQuestions : TList;
    FAnswer : TQuizQuestionType;
    FLastWrongQuestion : TQuizQuestionType;
    FLastWrongCount : Word;
    FCorrectCount : Word;
    FWrongCount : Word;
    FMaxWrongAnswersToAccept : Word;

    function CorrectAnswer(Answer : TQuizQuestionType) : Boolean; virtual;
    function CreateRandomQuestion(var Question : TQuizQuestionType) : Boolean; virtual;
    function GetCurrentQuestion : TQuizQuestionType;

    procedure SetAction(AAction : TQuizCommand); virtual;
    procedure SetAnswer(Answer : TQuizQuestionType); virtual;
    procedure Reset(AMode : TQuizResetMode); virtual;

    procedure ReciteOneQuizVoiceOf(AVoice : TQuizVoice);

  public
    constructor Create(AItemsParent : TWinControl; AMsgHandlerHwnd : THandle);
    destructor Destroy; override;

    procedure StartQuiz; virtual;
    procedure EndQuiz; virtual;
    procedure NextQuestion; virtual;
    procedure RepeatQuestion;

    property Action : TQuizCommand write SetAction;
    property Answer : TQuizQuestionType read FAnswer write SetAnswer;
    property CorrectResponses : Word read FCorrectCount;
    property IncorrectResponses : Word read FWrongCount;
    property MaxWrongAnswers : Word read FMaxWrongAnswersToAccept write FMaxWrongAnswersToAccept;
    property Questions : TList read FQuestions;
    property Question : TQuizQuestionType read GetCurrentQuestion;
    property Phase : TQuizPhase read FQuizPhase;
  end;

  TWordsModule = (wmLetters, wmSounds, wmShapes, wmConnectSounds, wmConnect);
  TModuleChangeHandler = procedure(AModule : TWordsModule) of object;

  TWordsForm = class(TForm)
    pnlMasterContainer: TPanel;
    barControl: TSpeedBar;
    btnModeExplore: TSpeedItem;
    btnModeLearn: TSpeedItem;
    btnModePlay: TSpeedItem;
    btnModuleStop: TSpeedItem;
    pnlWorkArea: TPanel;
    barWords: TSpeedBar;
    pnlHeader: TPanel;
    barVowels: TSpeedBar;
    btnVowelNone: TSpeedItem;
    btnVowelFatha: TSpeedItem;
    btnVowelKasra: TSpeedItem;
    btnVowelDhamma: TSpeedItem;
    btnVowelDhammathain: TSpeedItem;
    btnVowelFathathain: TSpeedItem;
    btnVowelKasrathain: TSpeedItem;
    btnVowelsMixed: TSpeedItem;
    btnAdvancedUser: TSpeedItem;
    barShapes: TSpeedBar;
    awActiveShapeIsolated: TArabicWordButton;
    awActiveShapeInitial: TArabicWordButton;
    awActiveShapeMedial: TArabicWordButton;
    awActiveShapeFinal: TArabicWordButton;
    seRepeatCount: TRxSpinEdit;
    lblRepeat: TLabel;
    awActiveWord: TArabicWordButton;
    btnRepeatQuestion: TSpeedItem;
    lblShapeEnd: TLabel;
    lblShapeMiddle: TLabel;
    lblShapeStart: TLabel;
    lblShapeAlone: TLabel;
    bvlControlBarBorder: TBevel;
    barLetters: TSpeedBar;
    btnConnectMode: TSpeedItem;
    scoreCorrect: TSevenChar;
    imgQuizScoreCorrect: TEPImage;
    imgQuizScoreIncorrect: TEPImage;
    scoreWrong: TSevenChar;
    pnlPlayScore: TPanel;
    barWordSectionSelect: TSpeedBar;
    btnWordSectionSelect1: TSpeedItem;
    btnWordSectionSelect2: TSpeedItem;
    btnWordSectionSelect3: TSpeedItem;
    btnWordSectionSelect4: TSpeedItem;
    btnVowelElongFatha: TSpeedItem;
    btnVowelElongKasra: TSpeedItem;
    btnVowelElongDhamma: TSpeedItem;
    barWordSetSelect: TSpeedBar;
    pnlWordTranslation: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure btnModuleStopClick(Sender: TObject);
    procedure WordMouseEnter(Sender: TObject);
    procedure WordMouseLeave(Sender: TObject);
    procedure LetterShapeClick(Sender: TObject);
    procedure VowelClick(Sender: TObject);
    procedure MixedVowelsClick(Sender: TObject);
    procedure ModeChangeClick(Sender: TObject);
    procedure NotifyLearnReciteFinish(Sender: TObject);
    procedure btnAdvancedUserClick(Sender: TObject);
    procedure ArabicWordButtonClick(Sender: TObject);
    procedure ArabicWordButtonRightClick(Sender: TObject);
    procedure tsWordsSelectChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure ConnectSoundLetterClick(Sender: TObject);
    procedure btnRepeatQuestionClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnConnectModeClick(Sender: TObject);
    procedure WordSetSelectBtnClick(Sender: TObject);
    procedure WordSectionSelectBtnClick(Sender: TObject);
    procedure ModeRightClick(Sender: TObject);
    procedure WordSectionSelectRightClick(Sender: TObject);
  private
    FHaveExternalData : Boolean;
    FModule : TWordsModule;
    FMode : TModuleMode;
    FLearnModePhase : TLearnModePhase;
    FLearningControlIdx : Integer;
    FLearningRepeatCount : Integer;
    FQuizControl : TQuizControl;
    FShapeButtonPressed : TLetterContext;
    FWords : TArabicWordsSet;
    FLetters : TArabicLettersSet;
    FModuleChandeHandlers : array[TWordsModule] of TModuleChangeHandler;
    FSelectedWordClass : TWordsClass;
    FSelectedWordSet : Integer;

    { module functions }
    procedure ChangeModule(AModule : TWordsModule);
    procedure HandleWordsModuleMsg(var Msg : TMessage); message CM_WORDSMODULE;
    procedure SetModule(AModule : TWordsModule);

    procedure InitializeControls;
    procedure LettersModuleHandler(AModule : TWordsModule);
    procedure SoundsModuleHandler(AModule : TWordsModule);
    procedure ShapesModuleHandler(AModule : TWordsModule);
    procedure ConnectSoundsModuleHandler(AModule : TWordsModule);
    procedure ConnectModuleHandler(AModule : TWordsModule);

    { mode functions }
    procedure ChangeMode(AMode : TModuleMode);
    function GetAdvancedUser : Boolean;
    function GetConnectLtrMode : Boolean;
    procedure HandleAppModeMsg(var Msg : TMessage); message CM_APPMODE;
    procedure HandleLearnModeMsg(var Msg : TLearnModeMessage); message CM_LEARNMODE;
    procedure HandleQuizModeMsg(var Msg : TQuizModeMessage); message CM_QUIZMODE;
    procedure SetMode(AMode : TModuleMode);
    procedure SetAdvancedUser(AAdvanced : Boolean);
    procedure SetConnectLtrMode(AConnectMode : Boolean);

    procedure SetWordClassIdx(Index : TWordsClass);
    function GetWordSetIdx : Integer;
    function GetWordSet : TArabicWordsSet;
    procedure SetWordSetIdx(Index : Integer);

    { utility functions }
    procedure CreateLetterButtons;
    procedure CreateWordButtons(nWordSet : Integer);
    procedure ChangeLetterShape(AContext : TLetterContext);
    procedure ChangeLetterVowel(AVowel : TArabicVowel);
  public
    property Mode : TModuleMode read FMode write SetMode;
    property Module : TWordsModule read FModule write SetModule;
    property Advanced : Boolean read GetAdvancedUser write SetAdvancedUser;
    property ConnectLetterMode : Boolean read GetConnectLtrMode write SetConnectLtrMode;
    property WordClass : TWordsClass read FSelectedWordClass write SetWordClassIdx;
    property WordSetIdx : Integer read GetWordSetIdx write SetWordSetIdx;
    property WordSet : TArabicWordsSet read GetWordSet;
  end;

implementation

uses VCLUtils, Main, SoundsMg, Study;

{$R *.DFM}

  constructor TQuizControl.Create(AItemsParent : TWinControl; AMsgHandlerHwnd : THandle);
  begin
    inherited Create;

    FMsgHandlerHwnd := AMsgHandlerHwnd;
    FQuizItemsParent := AItemsParent;
    FQuestions := TList.Create;
    FMaxWrongAnswersToAccept := 1;
  end;

  destructor TQuizControl.Destroy;
  begin
    FQuestions.Free;
    inherited Destroy;
  end;

  procedure TQuizControl.ReciteOneQuizVoiceOf(AVoice : TQuizVoice);
  const
    reQuizVoiceCounts : array[TQuizVoice] of Cardinal = (3, 6, 5, 1, 1);
    reQuizVoiceLastIdx : array[TQuizVoice] of Integer = (-1, -1, -1, -1, -1);
  var
    nVoiceIdx, nMaxVoiceIdx : Cardinal;
  begin
    if reQuizVoiceCounts[AVoice] > 1 then begin
      nMaxVoiceIdx := reQuizVoiceCounts[AVoice];
      repeat
        nVoiceIdx := Random(nMaxVoiceIdx);
      until nVoiceIdx <> reQuizVoiceLastIdx[AVoice];
      reQuizVoiceLastIdx[AVoice] := nVoiceIdx;
    end else
      nVoiceIdx := Pred(reQuizVoiceCounts[AVoice]);

    MainForm.PlayFmtSound('QZ0.%d.%d', [Ord(AVoice), nVoiceIdx], False, Nil);
  end;

  function TQuizControl.CorrectAnswer(Answer : TQuizQuestionType) : Boolean;
  begin
    Result := TQuizQuestionType(FQuestions.Last) = Answer;
  end;

  function TQuizControl.CreateRandomQuestion(var Question : TQuizQuestionType) : Boolean;
  begin
    Question := Nil;
    if (FQuizItemsParent.ControlCount <= 0) or (FQuestions.Count >= FQuizItemsParent.ControlCount) then
      Result := False
    else begin
      repeat
        Question := FQuizItemsParent.Controls[Random(FQuizItemsParent.ControlCount)];
      until FQuestions.IndexOf(Pointer(Question)) = -1;
      Result := True;
    end;
  end;

  function TQuizControl.GetCurrentQuestion : TQuizQuestionType;
  begin
    Result := FQuestions.Last;
  end;

  procedure TQuizControl.NextQuestion;
  var
    bMoreQuestions : Boolean;
    Question : TQuizQuestionType;
  begin
    Reset(rmWrongAnswerData);
    FQuizPhase := qpQuizzing;
    bMoreQuestions := CreateRandomQuestion(Question);
    if bMoreQuestions then begin
      FQuestions.Add(Pointer(Question));
      Action := qcNewQuestionComing;
      Action := qcAskQuestion;
    end else begin
      Action := qcQuestionsExhausted;
      EndQuiz;
    end;
  end;

  procedure TQuizControl.Reset(AMode : TQuizResetMode);
  begin
    if AMode = rmAll then begin
      FQuestions.Clear;
      FAnswer := Nil;
      FCorrectCount := 0;
      FWrongCount := 0;
      FQuizPhase := qpEnd;
      Action := qcUpdateScore;
    end;

    if (AMode = rmAll) or (AMode = rmWrongAnswerData) then begin
      FLastWrongQuestion := Nil;
      FLastWrongCount := 0;
    end;
  end;

  procedure TQuizControl.SetAction(AAction : TQuizCommand);
  var
    lParam : LongInt;
  begin
    lParam := -1;
    case AAction of
      qcQuizStart : lParam := 0;
      qcNewQuestionComing : lParam := 0;
      qcAskQuestion : lParam := LongInt(FQuestions.Last);
      qcAnnounceAnswerIsCorrect : lParam := LongInt(FAnswer);
      qcAnnounceAnswerIsIncorrect : lParam := LongInt(FAnswer);
      qcIdentifyCorrectAnswer : lParam := LongInt(FQuestions.Last);
      qcQuestionsExhausted : lParam := 0;
      qcUpdateScore : lParam := 0;
      qcQuizEnd : lParam := 0;
    end;

    PostMessage(FMsgHandlerHwnd, CM_QUIZMODE, Ord(AAction), lParam);
  end;

  procedure TQuizControl.SetAnswer(Answer : TQuizQuestionType);
  begin
    FAnswer := Answer;
    if CorrectAnswer(Answer) then begin
      if FLastWrongCount <= 0 then
        Inc(FCorrectCount);
      Action := qcUpdateScore;
      Action := qcAnnounceAnswerIsCorrect;

      NextQuestion;
    end else begin
      Action := qcAnnounceAnswerIsIncorrect;

      if FLastWrongQuestion <> TQuizQuestionType(FQuestions.Last) then begin
        FLastWrongQuestion := TQuizQuestionType(FQuestions.Last);
        Inc(FWrongCount);
        Inc(FLastWrongCount);
        Action := qcUpdateScore;
      end else begin
        Inc(FLastWrongCount);
        if FLastWrongCount > FMaxWrongAnswersToAccept then begin
          Action := qcIdentifyCorrectAnswer;
          { NextQuestion; <-- this must be called by event handler of IdentifyCorrectAnswer }
          Exit;
        end;
      end;

      Action := qcAskQuestion;
    end;
  end;

  procedure TQuizControl.StartQuiz;
  begin
    Reset(rmAll);
    FQuizPhase := qpStart;
    NextQuestion;
  end;

  procedure TQuizControl.EndQuiz;
  begin
    Reset(rmAll);
    FQuizPhase := qpEnd;
    Action := qcQuizEnd;
  end;

  procedure TQuizControl.RepeatQuestion;
  begin
    Action := qcAskQuestion;
  end;

{-----------------------------------------------------------------------------}

const
  ShapeButtonGroup = 4;
  VowelButtonGroup = 9;

function CreateLetterButton(Container : TStContainer;
                            Data : Pointer;
                            OtherData : Pointer) : Boolean; far;
var
  WordSet : TArabicWordsSet;
  Button : TArabicWordButton;
begin
  WordSet := TArabicWordsSet(Container);
  Button := TArabicWordButton.Create(TWordsForm(OtherData));
  Button.Parent := TWordsForm(OtherData).barWords;
  Button.ArabicFontSize := WordSet.FontSize;
  Button.SetBounds(0, 0, WordSet.CellSize.X, WordSet.CellSize.Y);
  Button.OnClick := TWordsForm(OtherData).ArabicWordButtonClick;
  Button.OnRightClick := TWordsForm(OtherData).ArabicWordButtonRightClick;
  Button.OnMouseEnter := TWordsForm(OtherData).WordMouseEnter;
  Button.OnMouseLeave := TWordsForm(OtherData).WordMouseLeave;
  Button.ArabicWord := PString(Data)^;
  Button.RecitationFile := StripShapeInfo(PString(Data)^);
  Button.DiaScale := 1.0;
end;

function CreateWordButton(Container : TStContainer;
                          Data : Pointer;
                          OtherData : Pointer) : Boolean; far;
const
  strReciteKeyFmt : String[15] = 'W%.2d.%.2d.%.2d';
var
  WordSet : TArabicWordsSet;
  Button : TArabicWordButton;
  strReciteKey : String;
  Form : TWordsForm;
begin
  WordSet := TArabicWordsSet(Container);
  Form := TWordsForm(OtherData);

  Button := TArabicWordButton.Create(TWordsForm(OtherData));
  Button.Parent := Form.barWords;
  Button.ArabicFontSize := WordSet.FontSize;
  Button.SetBounds(0, 0, WordSet.CellSize.X, WordSet.CellSize.Y);
  Button.OnClick := TWordsForm(OtherData).ArabicWordButtonClick;
  Button.OnRightClick := TWordsForm(OtherData).ArabicWordButtonRightClick;
  Button.OnMouseEnter := TWordsForm(OtherData).WordMouseEnter;
  Button.OnMouseLeave := TWordsForm(OtherData).WordMouseLeave;
  Button.ArabicWord := PString(Data)^;
  Button.DiaScale := WordSet.DiaScale;

  { if we have a word translation, be sure to show the translation panel }
  if (Button.WordTranslation <> '') and (not Form.pnlWordTranslation.Visible) then
    Form.pnlWordTranslation.Visible := True;

  FmtStr(strReciteKey, strReciteKeyFmt,
         [Ord(Form.WordClass), Form.WordSetIdx, WordSet.OriginalList.IndexOf(Data)]);
  Button.RecitationFile := strReciteKey;
end;

procedure TWordsForm.FormCreate(Sender: TObject);
const
  chExternalDataMarker : Char = '*';
var
  nWordsSetIdx : Integer;
  strAppDataFile, strTabName : String;
  L : TArabicAlphaName;
  btnLetter : TArabicWordButton;
  LArrange : TArrangeInfo;
begin
  MakeFullScreen(Self, pnlMasterContainer);

  FLetters := TArabicLettersSet.Create;

  FQuizControl := TQuizControl.Create(barWords, Self.Handle);
  FModuleChandeHandlers[wmLetters] := LettersModuleHandler;
  FModuleChandeHandlers[wmSounds] := SoundsModuleHandler;
  FModuleChandeHandlers[wmShapes] := ShapesModuleHandler;
  FModuleChandeHandlers[wmConnectSounds] := ConnectSoundsModuleHandler;
  FModuleChandeHandlers[wmConnect] := ConnectModuleHandler;

  { create the letters that will go on the letters bar}
  for L := aaAlif to aaYaa do begin
    btnLetter := TArabicWordButton.Create(Self);
    btnLetter.Parent := barLetters;
    btnLetter.Visible := True;
    btnLetter.ArabicFontSize := 30;
    btnLetter.ArabicWord := IntToStr(Ord(L));
    btnLetter.WordColor := clNavy;
    btnLetter.Tag := Ord(L);
    btnLetter.OnClick := ConnectSoundLetterClick;
    btnLetter.Hint := '';
  end;

  with LArrange do begin
    Randomize := False;
    ArrangeXType := axRightToLeft;
    BorderWidth := 2;
    CellSize := Point((barLetters.Width - (2 * BorderWidth)) div 14,
                      (barLetters.Height - (2 * BorderWidth)) div 2);
    CellSpacing := Point(0, 0);
    ArrangeControls(barLetters, LArrange);
  end;

  WordClass := wcStart;
end;

procedure TWordsForm.FormDestroy(Sender: TObject);
begin
  FLetters.Free;
  FQuizControl.Free;
end;

procedure TWordsForm.InitializeControls;
begin
  { hide all module-specific controls }
  ClearControls(barWords);
  pnlHeader.Hide;
  barShapes.Hide;
  barVowels.Hide;
  barLetters.Hide;
  btnConnectMode.Visible := False;
  btnAdvancedUser.Visible := False;
  barWordSectionSelect.Hide;
  barWordSetSelect.Hide;
end;

procedure TWordsForm.LettersModuleHandler(AModule : TWordsModule);
begin
  InitializeControls;
  FModule := wmLetters;
  btnAdvancedUser.Visible := True;
  btnConnectMode.Visible := True;
  FLetters.Vowels := [avNone];
  FLetters.Shapes := [lcIsolated];
  CreateLetterButtons;
end;

procedure TWordsForm.SoundsModuleHandler(AModule : TWordsModule);
begin
  InitializeControls;
  FModule := wmSounds;
  btnAdvancedUser.Visible := True;
  btnConnectMode.Visible := True;
  pnlHeader.Show;
  barVowels.Show;
  FLetters.Shapes := [lcIsolated];
  ChangeLetterVowel(GetRandomVowel(vsLetterVowels));
end;

procedure TWordsForm.ShapesModuleHandler(AModule : TWordsModule);
begin
  InitializeControls;
  FModule := wmShapes;
  btnAdvancedUser.Visible := True;
  btnConnectMode.Visible := True;
  pnlHeader.Show;
  barShapes.Show;
  barVowels.Show;
  FLetters.Vowels := [avNone];
  ChangeLetterShape(GetRandomLetterShape([lcInitial, lcMedial, lcFinal]));
end;

procedure TWordsForm.ConnectSoundsModuleHandler(AModule : TWordsModule);
var
  nConnectSetIdx : Integer;
begin
  InitializeControls;
  FModule := wmConnectSounds;
  pnlHeader.Show;
  barLetters.Show;

  WordClass := wcConnectSounds;
end;

procedure TWordsForm.ConnectModuleHandler(AModule : TWordsModule);
begin
  InitializeControls;
  FModule := wmConnect;
  pnlHeader.Show;
  barWordSectionSelect.Show;
  barWordSetSelect.Show;
  WordSetIdx := 0;
end;

procedure TWordsForm.ChangeModule(AModule : TWordsModule);
begin
  if Mode <> mmExplore then begin
    Mode := mmExplore;   { change the mode to explore mode, then try changing module again later }
    SetModule(AModule);
    Exit;
  end;

  if Assigned(FModuleChandeHandlers[AModule]) then
    FModuleChandeHandlers[AModule](AModule);

  Mode := mmExplore;
end;

procedure TWordsForm.HandleWordsModuleMsg(var Msg : TMessage);
begin
  case Msg.wParam of
    MP_CHANGEMODULE : ChangeModule(TWordsModule(Msg.lParam));
  end;
end;

procedure TWordsForm.SetModule(AModule : TWordsModule);
begin
  PostMessage(Handle, CM_WORDSMODULE, MP_CHANGEMODULE, LongInt(Ord(AModule)));
end;

procedure TWordsForm.ChangeMode(AMode : TModuleMode);

  procedure ExploreStart;
  begin
    btnModeExplore.Visible := True;
    btnModeLearn.Visible := True;
    btnModePlay.Visible := True;
    btnAdvancedUser.Visible := Module in [wmLetters, wmSounds, wmShapes];
    btnConnectMode.Visible := Module in [wmLetters, wmSounds, wmShapes];
    btnModeExplore.Down := True;
    barShapes.Visible := Module = wmShapes;
    barVowels.Visible := Module in [wmSounds, wmShapes];
    barLetters.Visible := Module = wmConnectSounds;
    barWordSetSelect.Visible := Module in [wmConnect];
    barWordSectionSelect.Visible := Module in [wmConnect];
  end;

  procedure LearnStart;
  begin
    btnModeLearn.Down := True;
    lblRepeat.Visible := True;
    seRepeatCount.Visible := True;
    barControl.Update;
    pnlHeader.Update;

    PostMessage(Handle, CM_LEARNMODE, Ord(lcLearnStart), 0);
  end;

  procedure LearnStop;
  begin
    PostMessage(Handle, CM_LEARNMODE, Ord(lcLearnStop), 0);
  end;

  procedure QuizStart;
  begin
    btnModePlay.Down := True;
    btnRepeatQuestion.Visible := True;
    pnlPlayScore.Visible := True;
    barControl.Update;
    pnlHeader.Update;

    FQuizControl.StartQuiz;
  end;

  procedure QuizStop;
  begin
    FQuizControl.EndQuiz;
  end;

begin
  case FMode of
    mmExplore : ;
    mmLearn :
      case FLearnModePhase of
        lmpEnd : ;
        lmpRequestStop : Exit; { wait until stop is called }
        lmpStart, lmpLearning :
          begin
            LearnStop;  { stop the learning mode and try to change mode again later }
            SetMode(AMode);
            Exit;
          end;
      end;
    mmPlay :
      case FQuizControl.Phase of
        qpEnd  : ;
        qpStart,
        qpQuizzing :
          begin
            QuizStop;   { stop the quiz mode and try changing mode again later }
            SetMode(AMode); { do a post-message, causing this method to be called again }
            Exit;
          end;
      end;
  end;

  { hide all mode-specific controls, each mode displays what it needs }
  btnModeExplore.Visible := False;
  btnModeLearn.Visible := False;
  btnModePlay.Visible := False;
  btnAdvancedUser.Visible := False;
  btnConnectMode.Visible := False;
  barShapes.Visible := False;
  barVowels.Visible := False;
  pnlPlayScore.Visible := False;
  lblRepeat.Visible := False;
  seRepeatCount.Visible := False;
  btnRepeatQuestion.Visible := False;
  barLetters.Visible := False;
  barWordSetSelect.Visible := False;
  barWordSectionSelect.Visible := False;

  FMode := AMode;
  case AMode of
    mmExplore : ExploreStart;
    mmLearn : LearnStart;
    mmPlay : QuizStart;
  end;
end;

procedure TWordsForm.HandleAppModeMsg(var Msg : TMessage);
begin
  case Msg.wParam of
    MP_CHANGEMODE : ChangeMode(TModuleMode(Msg.lParam));
  end;
end;

procedure TWordsForm.HandleLearnModeMsg(var Msg : TLearnModeMessage);
begin
  case Msg.eLearnCmd of
    lcLearnStart :
      if barWords.ControlCount > 0 then begin
        SetControlsStatus(barWords, False, False);
        PostMessage(Handle, CM_LEARNMODE, Ord(lcLearnNext), 0);
        FLearnModePhase := lmpStart;
      end;
    lcLearnNext  :
      if FLearnModePhase in [lmpStart, lmpLearning] then begin
        FLearnModePhase := lmpLearning;
        barWords.Controls[Msg.wLearnCtrlIdx].Enabled := False;
        barWords.Controls[Msg.wLearnCtrlIdx].Show;
        barWords.Update;
        FLearningControlIdx := Msg.wLearnCtrlIdx;
        FLearningRepeatCount := Msg.wRepeatCount;
        MainForm.PlaySoundFile((barWords.Controls[Msg.wLearnCtrlIdx] as TArabicWordButton).RecitationFile,
                               True, NotifyLearnReciteFinish);
      end;
    lcLearnStop :
      begin
        FLearnModePhase := lmpRequestStop;
        PostMessage(Handle, CM_LEARNMODE, Ord(lcLearnEnd), 0);
      end;
    lcLearnEnd :
      begin
        SetControlsStatus(barWords, True, True);
        FLearnModePhase := lmpEnd;
        PostMessage(Handle, CM_APPMODE, MP_CHANGEMODE, Ord(mmExplore));
      end;
  end;
end;

procedure TWordsForm.HandleQuizModeMsg(var Msg : TQuizModeMessage);
var
  StudyForm : TStudyForm;
begin
  case Msg.eQuizCmd of
    qcQuizStart : ;
    qcQuizEnd :
        begin
          { in case any controls were hidden, display them now }
          SetControlsStatus(barWords, True, True);
          Mode := mmExplore;
        end;
    qcNewQuestionComing :
        begin
          { in case any controls were hidden, display them now }
          SetControlsStatus(barWords, True, True);
        end;
    qcAskQuestion :
        begin
          FQuizControl.ReciteOneQuizVoiceOf(qvAsk);
          MainForm.PlaySoundFile(TArabicWordButton(Msg.lQuizData).RecitationFile, False, Nil);
        end;
    qcAnnounceAnswerIsCorrect :
        begin
          MainForm.PlaySoundFile('QZRIGHT', False, Nil);
          FQuizControl.ReciteOneQuizVoiceOf(qvCorrect);
        end;
    qcAnnounceAnswerIsInCorrect :
        begin
          MainForm.PlaySoundFile('QZWRONG', False, Nil);
          FQuizControl.ReciteOneQuizVoiceOf(qvIncorrect);
          FQuizControl.ReciteOneQuizVoiceOf(qvIdentifyChosen);
          MainForm.PlaySoundFile(TArabicWordButton(Msg.lQuizData).RecitationFile, False, Nil);
          HideRandomHalfOfControls(barWords, TControl(FQuizControl.Questions.Last));
        end;
    qcUpdateScore :
        begin
          scoreCorrect.Value := FQuizControl.CorrectResponses;
          scoreWrong.Value := FQuizControl.IncorrectResponses;
        end;
    qcIdentifyCorrectAnswer :
        begin
          FQuizControl.ReciteOneQuizVoiceOf(qvIdentifyCorrect);
          Application.CreateForm(TStudyForm, StudyForm);
          StudyForm.StudyWord := TArabicWordButton(FQuizControl.Question);
          StudyForm.ShowModal;
          StudyForm.Free;
          Update; { don't play sound without updating paint events }
          FQuizControl.NextQuestion;
        end;
    qcQuestionsExhausted : ;
  end;
end;

procedure TWordsForm.SetMode(AMode : TModuleMode);
begin
  PostMessage(Handle, CM_APPMODE, MP_CHANGEMODE, LongInt(AMode));
end;

procedure TWordsForm.btnModuleStopClick(Sender: TObject);
begin
  if Mode = mmExplore then
    Close
  else
    Mode := mmExplore;
end;

procedure TWordsForm.WordMouseEnter(Sender: TObject);
begin
  MainForm.ResSounds.PlaySound('IDW_TINK', spmAsync);
  if FModule = wmShapes then begin
    awActiveShapeFinal.ArabicWord := FormatLetter((Sender as TArabicWordButton).ArabicWord, -1, Ord(avNone), Ord(lcFinal));
    awActiveShapeMedial.ArabicWord := FormatLetter((Sender as TArabicWordButton).ArabicWord, -1, Ord(avNone), Ord(lcMedial));
    awActiveShapeInitial.ArabicWord := FormatLetter((Sender as TArabicWordButton).ArabicWord, -1, Ord(avNone), Ord(lcInitial));
    awActiveShapeIsolated.ArabicWord :=
      FormatLetter((Sender as TArabicWordButton).ArabicWord, -1, Ord(avNone), Ord(lcIsolated));
  end else if FModule in [wmConnect, wmConnectSounds] then begin
    awActiveWord.ArabicWord := (Sender as TArabicWordButton).ArabicWord;
    if (Sender as TArabicWordButton).WordTranslation <> '' then
      pnlWordTranslation.Caption := (Sender as TArabicWordButton).WordTranslation;
  end;
end;

procedure TWordsForm.WordMouseLeave(Sender: TObject);
begin
  if FModule in [wmConnect, wmConnectSounds] then begin
    awActiveWord.ArabicWord := '';
    pnlWordTranslation.Caption := '';
  end;
end;

procedure TWordsForm.ChangeLetterShape(AContext : TLetterContext);
begin
  case AContext of
    lcIsolated : if not awActiveShapeIsolated.Down then awActiveShapeIsolated.Down := True;
    lcInitial : if not awActiveShapeInitial.Down then awActiveShapeInitial.Down := True;
    lcMedial : if not awActiveShapeMedial.Down then awActiveShapeMedial.Down := True;
    lcFinal : if not awActiveShapeFinal.Down then awActiveShapeFinal.Down := True;
  end;

  FLetters.Shapes := [AContext];
  FShapeButtonPressed := AContext;
  CreateLetterButtons;
end;

procedure TWordsForm.ChangeLetterVowel(AVowel : TArabicVowel);
begin
  PushTaggedItemDown(barVowels, Ord(AVowel));
  FLetters.Vowels := [AVowel];
  CreateLetterButtons;
end;

procedure TWordsForm.CreateLetterButtons;

  procedure ModifyArrangement;
  begin
    case Module of
      wmLetters :
        begin
          if not ConnectLetterMode then begin
            FLetters.FontSize := 80;
            FLetters.CellSize := Point(89, 90);
            FLetters.CellPadding := Point(0, 0);
          end else begin
            FLetters.FontSize := 70;
            FLetters.CellSize := Point(75, 90);
            FLetters.CellPadding := Point(0, 0);
          end;
        end;
      wmSounds,
      wmShapes :
        begin
          if FLetters.Vowels = [avNone] then
            FLetters.FontSize := 60
          else
            FLetters.FontSize := 45;
          if not ConnectLetterMode then begin
            FLetters.CellSize := Point(75, 80);
            FLetters.CellPadding := Point(0, 5);
          end else begin
            FLetters.CellSize := Point(75, 68);
            FLetters.CellPadding := Point(0, 5);
          end;

          { according to Amir, lamAlif shouldn't show in these circumstances}
          if not ((avFatha in FLetters.Vowels) or
             (avFathathain in FLetters.Vowels)) or
             (FLetters.Vowels = vsLetterVowels) then
            FLetters.Letters := FLetters.Letters - [aaLamAlif];
        end;
    end;
  end;

var
  ArrangeData : TArrangeInfo;
begin
  ClearControls(barWords);
  if btnAdvancedUser.Down then
    FLetters.Order := osRamdomizedDisplay
  else
    FLetters.Order := osInOrder;

  if btnConnectMode.Down then
    FLetters.Letters := FLetters.Letters + ConnectLetterNames
  else
    FLetters.Letters := FLetters.Letters - ConnectLetterNames;

  ModifyArrangement;

  pnlWordTranslation.Hide;
  FLetters.Iterate(CreateLetterButton, True, Self);
  ArrangeData := FLetters.Arrangement;
  ArrangeControls(barWords, ArrangeData);
end;

procedure TWordsForm.CreateWordButtons(nWordSet : Integer);
var
  ArrangeData : TArrangeInfo;
begin
  if (nWordSet < 0) or (nWordSet >= MainForm.WordsSets[FSelectedWordClass].Count) then
    Exit;

  FWords := TArabicWordsSet(MainForm.WordsSets[FSelectedWordClass][nWordSet]);
  awActiveWord.Visible := FWords.ShowConnect;
  pnlWordTranslation.Hide;
  ClearControls(barWords);
  FWords.Iterate(CreateWordButton, True, Self);
  ArrangeData := FWords.Arrangement;
  ArrangeControls(barWords, ArrangeData);
end;

procedure TWordsForm.SetWordClassIdx(Index : TWordsClass);
var
  btnWordSetIdx : TRxSpeedButton;
  WSArrange : TArrangeInfo;
  N : Cardinal;
begin
  FSelectedWordClass := Index;
  PushTaggedItemDown(barWordSectionSelect, Ord(Index));

  ClearControls(barWordSetSelect);
  if MainForm.WordsSets[FSelectedWordClass].Count > 0 then begin
    for N := 0 to (MainForm.WordsSets[FSelectedWordClass].Count-1) do begin
      btnWordSetIdx := TRxSpeedButton.Create(Self);
      btnWordSetIdx.Parent := barWordSetSelect;
      btnWordSetIdx.Caption := IntToStr(N+1);
      btnWordSetIdx.Flat := True;
      btnWordSetIdx.Transparent := True;
      btnWordSetIdx.GroupIndex := 10;
      btnWordSetIdx.Visible := True;
      btnWordSetIdx.Tag := N;
      btnWordSetIdx.OnClick := WordSetSelectBtnClick;
      btnWordSetIdx.OnMouseEnter := MainForm.PlayButtonEnterSound;
      btnWordSetIdx.Hint := 'Lesson ' + IntToStr(N+1) + ' of ' + IntToStr(MainForm.WordsSets[FSelectedWordClass].Count);
    end;

    with WSArrange do begin
      Randomize := False;
      ArrangeXType := axLeftToRight;
      BorderWidth := 2;
      CellSize := Point(20, 20);
      CellSpacing := Point(0, 0);
      ArrangeControls(barWordSetSelect, WSArrange);
    end;
  end;

  WordSetIdx := 0;
end;

function TWordsForm.GetWordSetIdx : Integer;
begin
  Result := FSelectedWordSet;
end;

function TWordsForm.GetWordSet : TArabicWordsSet;
begin
  Result := MainForm.WordsSets[FSelectedWordClass][FSelectedWordSet];
end;

procedure TWordsForm.SetWordSetIdx(Index : Integer);
begin
  FSelectedWordSet := Index;
  PushTaggedItemDown(barWordSetSelect, Index);
  CreateWordButtons(FSelectedWordSet);
end;

procedure TWordsForm.LetterShapeClick(Sender: TObject);
begin
  MainForm.PlayFmtSound('AC%d.%d', [MainForm.PersonalityId, (Sender as TArabicWordButton).Tag], True, Nil);
  ChangeLetterShape(TLetterContext((Sender as TArabicWordButton).Tag));
end;

procedure TWordsForm.VowelClick(Sender: TObject);
begin
  if TArabicVowel((Sender as TRxSpeedButton).Tag) <> avNone then
    MainForm.PlayFmtSound('AV%d', [(Sender as TRxSpeedButton).Tag], True, Nil);
  ChangeLetterVowel(TArabicVowel((Sender as TRxSpeedButton).Tag));
end;

procedure TWordsForm.MixedVowelsClick(Sender: TObject);
begin
  FLetters.Vowels := vsLetterVowels;
  CreateLetterButtons;
end;

procedure TWordsForm.ModeChangeClick(Sender: TObject);
begin
  Mode := TModuleMode((Sender as TRxSpeedButton).Tag);
end;

procedure TWordsForm.NotifyLearnReciteFinish(Sender: TObject);
begin
  Inc(FLearningRepeatCount);

  if FLearningRepeatCount < seRepeatCount.Value then
    PostMessage(Handle, CM_LEARNMODE, Ord(lcLearnNext), MakeLong(FLearningControlIdx, FLearningRepeatCount))
  else if FLearningControlIdx < barWords.ControlCount-1 then
    PostMessage(Handle, CM_LEARNMODE, Ord(lcLearnNext), MakeLong(FLearningControlIdx+1, 0))
  else
    PostMessage(Handle, CM_LEARNMODE, Ord(lcLearnEnd), 0)
end;

function TWordsForm.GetAdvancedUser : Boolean;
begin
  Result := btnAdvancedUser.Down;
end;

function TWordsForm.GetConnectLtrMode : Boolean;
begin
  Result := btnConnectMode.Down;
end;

procedure TWordsForm.SetAdvancedUser(AAdvanced : Boolean);
begin
  if AAdvanced and (not btnAdvancedUser.Down) then
    btnAdvancedUser.Down := True;
  if (Module = wmShapes) then begin
    if AAdvanced then
      FLetters.Shapes := AllLetterShapes
    else begin
      FLetters.Shapes := [FShapeButtonPressed];
    end;
  end;

  CreateLetterButtons;
end;

procedure TWordsForm.SetConnectLtrMode(AConnectMode : Boolean);
begin
  if AConnectMode and (not btnConnectMode.Down) then
    btnConnectMode.Down := True;
  CreateLetterButtons;
end;

procedure TWordsForm.btnAdvancedUserClick(Sender: TObject);
begin
  Advanced := (Sender as TRxSpeedButton).Down;
end;

procedure TWordsForm.btnConnectModeClick(Sender: TObject);
begin
  ConnectLetterMode := (Sender as TRxSpeedButton).Down;
end;

procedure TWordsForm.ArabicWordButtonClick(Sender: TObject);
begin
  case FMode of
    mmExplore : MainForm.PlaySoundFile((Sender as TArabicWordButton).RecitationFile, True, Nil);
    mmLearn : ;
    mmPlay : FQuizControl.Answer := Sender as TControl;
  end;
end;

procedure TWordsForm.ArabicWordButtonRightClick(Sender: TObject);
var
  StudyForm : TStudyForm;
  strSimilar : String;
begin
  case FMode of
    mmExplore :
      begin
        Application.CreateForm(TStudyForm, StudyForm);
        StudyForm.StudyWord := (Sender as TArabicWordButton);

        if FModule in [wmLetters, wmSounds, wmShapes] then begin
          StudyForm.awStudyWord.DiaScale := 0.50;
          strSimilar := MainForm.SimilarSounds.Similar[(Sender as TArabicWordButton).ArabicWord];
          if strSimilar <> '' then
            StudyForm.ShowCompareWord(strSimilar, StripShapeInfo(strSimilar));
        end;

        StudyForm.ShowModal;
        StudyForm.Free;
      end;
    mmLearn : ;
    mmPlay : ;
  end;
end;

procedure TWordsForm.ConnectSoundLetterClick(Sender: TObject);
begin
  {CreateConnectSoundButtons(TArabicAlphaName((Sender as TArabicWordButton).Tag))}
  WordSetIdx := (Sender as TArabicWordButton).Tag;
end;

procedure TWordsForm.tsWordsSelectChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  CreateWordButtons(NewTab);
end;

procedure TWordsForm.btnRepeatQuestionClick(Sender: TObject);
begin
  if FMode = mmPlay then
    FQuizControl.RepeatQuestion;
end;

procedure TWordsForm.WordSetSelectBtnClick(Sender: TObject);
begin
  WordSetIdx := (Sender as TRxSpeedButton).Tag;
end;

procedure TWordsForm.WordSectionSelectBtnClick(Sender: TObject);
begin
  WordClass := TWordsClass((Sender as TRxSpeedButton).Tag);
end;

procedure TWordsForm.ModeRightClick(Sender: TObject);
begin
  MainForm.PlayFmtSound('EXM%d.%d', [MainForm.PersonalityId,
                                     (Sender as TRxSpeedButton).Tag], True, Nil);
  MainForm.ShowOneHintOnRightClick(Sender);
end;

procedure TWordsForm.WordSectionSelectRightClick(Sender: TObject);
begin
  MainForm.PlayFmtSound('CL%d.%d', [MainForm.PersonalityId,
                                    (Sender as TRxSpeedButton).Tag], True, Nil);
  MainForm.ShowOneHintOnRightClick(Sender);
end;

end.

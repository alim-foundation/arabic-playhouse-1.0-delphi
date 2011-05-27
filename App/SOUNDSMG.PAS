unit SoundsMg;
  {-play sounds kept in a resource file}

interface

uses WinTypes, WinProcs, SysUtils, MMSystem, StDict;

type
  TResSoundPlayMode = (spmAsync, spmWaitForEnd);

  TResSoundsManager = class(TStDictionary)
  protected
    FPlayMode : TResSoundPlayMode;
    FResInstance : THandle;

  public
    constructor Create;

    function AddSoundResource(strResId : String) : Boolean;
    procedure PlaySound(strId : String; AMode : TResSoundPlayMode);

    property ResInstance : THandle read FResInstance write FResInstance;
  end;

implementation

type
  PSoundData = ^TSoundData;
  TSoundData =
    record
      strId : String;           { filename or resource id }
      hFindResHandle : THandle; { value returned from FindResource }
      hSndData : THandle;       { the resource handle or 0 if strId not found }
      pSndData : Pointer;       { the resource data far pointer, nil if strId not found }
    end;

procedure DisposeSoundData(Data : Pointer); far;
var
  bReferencesRemain : Boolean;
begin
  with PSoundData(Data)^ do begin
    bReferencesRemain := UnlockResource(hSndData);
    if not bReferencesRemain then
      FreeResource(hSndData);
  end;
  Dispose(PSoundData(Data));
end;

constructor TResSoundsManager.Create;
begin
  inherited Create(50);
  DisposeData := DisposeSoundData;
end;

function TResSoundsManager.AddSoundResource(strResId : String) : Boolean;
var
  pszResName : array[0..254] of char;
  pData : PSoundData;
begin
  Result := False;

  New(pData);
  FillChar(pData^, SizeOf(TSoundData), 0);
  pData^.strId := strResId;

  { if it's a resource, load it now }
  with pData^ do begin
    hFindResHandle := FindResource(FResInstance, StrPCopy(pszResName, strResId), RT_RCDATA);
    if hFindResHandle = 0 then
      Exit;

    hSndData := LoadResource(FResInstance, hFindResHandle);
    if hSndData = 0 then
      Exit;

    pSndData := LockResource(hSndData);
    if pSndData = Nil then begin
      FreeResource(hSndData);
      Exit;
    end;

    Add(strId, pData);
    Result := True;
  end;
end;

procedure TResSoundsManager.PlaySound(strId : String; AMode : TResSoundPlayMode);
var
  pszResName : array[0..254] of char;
  pData : Pointer;
  wFlags : Word;
begin
  wFlags := 0;
  case AMode of
    spmAsync : wFlags := SND_ASYNC;
    spmWaitForEnd : wFlags := SND_SYNC;
  end;

  if Exists(strId, pData) then
    SndPlaySound(PSoundData(pData)^.pSndData, SND_MEMORY or wFlags)
  else
    SndPlaySound(StrPCopy(pszResName, strId), wFlags);
end;

end.

unit FHIR.Server.Kernel;

{
Copyright (c) 2011+, HL7 and Health Intersections Pty Ltd (http://www.healthintersections.com.au)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of HL7 nor the names of its contributors may be used to
   endorse or promote products derived from this software without specific
   prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
}


{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{
Copyright (c) 2001-2013, Health Intersections Pty Ltd (http://www.healthintersections.com.au)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of HL7 nor the names of its contributors may be used to
   endorse or promote products derived from this software without specific
   prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
}

interface

Uses
  Windows, SysUtils, Classes, IniFiles, ActiveX, ComObj,
  FHIR.Support.Exceptions,
  FHIR.Support.Service, FHIR.Support.System, FHIR.Support.Strings, FHIR.Support.Objects,
  FHIR.Web.Fetcher,
  FHIR.Snomed.Importer, FHIR.Snomed.Services, FHIR.Snomed.Expressions, FHIR.Tx.RxNorm, FHIR.Tx.Unii,
  FHIR.Loinc.Importer, FHIR.Loinc.Services,
  FHIR.Database.Manager, FHIR.Database.ODBC, FHIR.Database.Dialects, FHIR.Database.SQLite,
  FHIR.Base.Factory, FHIR.Cache.PackageManager, FHIR.Base.Parser, FHIR.Base.Lang,
  {$IFDEF FHIR2} FHIR.R2.Factory, {$ENDIF}
  {$IFDEF FHIR3} FHIR.R3.Factory, {$ENDIF}
  {$IFDEF FHIR4} FHIR.R4.Factory, {$ENDIF}
  FHIR.Version.Resources, FHIR.Version.Parser,
  FHIR.Tx.Server,
  FHIR.Server.Storage,
  FHIR.Server.Web, FHIR.Server.DBInstaller, FHIR.Version.Constants, FHIR.Server.Database, FHIR.Base.Objects, FHIR.Version.PathEngine,
  FHIR.Server.Constants, FHIR.Server.Context, FHIR.Server.Utilities, FHIR.Server.WebSource,
  FHIR.Scim.Server, FHIR.CdsHooks.Service, FHIR.Server.Javascript;

Type
  TFHIRServerDataStore = class (TFHIRNativeStorageService)
  public
    function createOperationContext(lang : String) : TFHIROperationEngine; override;
    Procedure Yield(op : TFHIROperationEngine; e : Exception); override;
  end;

  TFHIRService = class (TSystemService)
  private
    FStartTime : cardinal;
    TestMode : Boolean;
    FIni : TFHIRServerIniFile;
    FDb : TKDBManager;
    FTerminologyServer : TTerminologyServer;
    FWebServer : TFhirWebServer;

    FNotServing : boolean;
    FLoadStore : boolean;
    FInstaller : boolean;
    Fcallback: TInstallerCallback;
    FRunNumber : integer;

    function connectToDB(name : String; max, timeout : integer; driver, server, database, username, password : String; forCreate : boolean) : TKDBManager;
    procedure ConnectToDatabase(noCheck : boolean = false);
    procedure LoadTerminologies;
    procedure InitialiseRestServer;
    procedure StopRestServer;
    procedure UnloadTerminologies;
    procedure CloseDatabase;
    procedure validate;
    procedure InstallerCallBack(i : integer; s : String);
    procedure cb(i : integer; s : WideString);
    procedure identifyValueSets;
    function RegisterValueSet(id: String; conn: TKDBConnection): integer;
    function fetchFromUrl(fn : String; var bytes : TBytes) : boolean;
    function makeFactory : TFHIRFactory;
  protected
    function CanStart : boolean; Override;
    procedure postStart; override;
    procedure DoStop; Override;
    procedure dump; override;
  public
    Constructor Create(const ASystemName, ADisplayName, AIniName: String);
    Destructor Destroy; override;

    procedure Load(fn : String);
    procedure LoadbyProfile(fn : String; init : boolean);
    procedure Index;
    procedure InstallDatabase;
    procedure UnInstallDatabase;

    property NotServing : boolean read FNotServing write FNotServing;
    property callback : TInstallerCallback read Fcallback write Fcallback;
  end;

procedure ExecuteFhirServer;

implementation

uses
  FHIR.Debug.Logging, JclDebug;

procedure CauseException;
begin
  raise EFHIRException.create('Test');
end;

procedure ExecuteFhirServer;
var
  iniName : String;
  svcName : String;
  dispName : String;
  dir, fn, ver, ldate, lver, dest : String;
  svc : TFHIRService;
  ini : TIniFile;
  factory : TFHIRFactory;
begin
  AllocConsole;
  try
    Consolelog := true;
    if FindCmdLineSwitch('log', fn, true, [clstValueNextParam]) then
    begin
      filelog := true;
      logfile := fn;
    end;

    CoInitialize(nil);
    if not FindCmdLineSwitch('ini', iniName, true, [clstValueNextParam]) then
      iniName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'fhirserver.ini';
    if not FindCmdLineSwitch('name', svcName, true, [clstValueNextParam]) then
      svcName := 'FHIRServer';
    if not FindCmdLineSwitch('title', dispName, true, [clstValueNextParam]) then
      dispName := 'FHIR Server';
    iniName := iniName.replace('.dstu', '.dev');

    if JclExceptionTrackingActive then
      logt('FHIR Service '+SERVER_VERSION+'. Using ini file '+iniName+' with stack dumps on')
    else
      logt('FHIR Service '+SERVER_VERSION+'. Using ini file '+iniName+' (no stack dumps)');
    if filelog then
      logt('Log File = '+logfile);
    logt('FHIR Version '+FHIR_GENERATED_VERSION);
    dispName := dispName + ' '+SERVER_VERSION+' (FHIR v '+FHIR_GENERATED_VERSION+')';

    svc := TFHIRService.Create(svcName, dispName, iniName);
    try
      factory := svc.makeFactory;
      try
        GJsHost := TJsHost.Create(svc.FIni.ReadString(voMaybeVersioned, 'Javascript', 'path', ''), factory);
        try
          if FindCmdLineSwitch('installer') then
          begin
            svc.FInstaller := true;
            svc.callback := svc.InstallerCallBack;
          end;

          svc.FLoadStore := not FindCmdLineSwitch('noload');
          if FindCmdLineSwitch('mount') then
          begin
            svc.InstallDatabase;
            if FindCmdLineSwitch('unii', fn, true, [clstValueNextParam]) then
              ImportUnii(fn, svc.Fdb);
          end
          else if FindCmdLineSwitch('unmount') then
            svc.UninstallDatabase
          else if FindCmdLineSwitch('remount') then
          begin
            svc.DebugMode := true;
            svc.FNotServing := true;
            svc.UninstallDatabase;
            svc.InstallDatabase;
            if FindCmdLineSwitch('unii', fn, true, [clstValueNextParam]) then
              ImportUnii(fn, svc.Fdb);
            if FindCmdLineSwitch('profile', fn, true, [clstValueNextParam]) then
              svc.LoadByProfile(fn, true)
            else if FindCmdLineSwitch('load', fn, true, [clstValueNextParam]) then
              svc.Load(fn);
          end
          else if FindCmdLineSwitch('load', fn, true, [clstValueNextParam]) then
          begin
            svc.DebugMode := true;
            svc.FNotServing := true;
            svc.Load(fn);
          end
          else if FindCmdLineSwitch('txdirect') then
          begin
            svc.UninstallDatabase;
            svc.InstallDatabase;
            svc.ConsoleExecute;
          end
          else if FindCmdLineSwitch('profile', fn, true, [clstValueNextParam]) then
            svc.LoadByProfile(fn, false)
          else if FindCmdLineSwitch('validate') then
          begin
            svc.FNotServing := true;
            svc.validate;
          end
          else if FindCmdLineSwitch('index') then
            svc.index
          else if FindCmdLineSwitch('snomed-rf2', dir, true, [clstValueNextParam]) then
          begin
            FindCmdLineSwitch('sver', ver, true, [clstValueNextParam]);
            if not FindCmdLineSwitch('sdest', dest, true, [clstValueNextParam]) then
              dest := svc.FIni.ReadString(voVersioningNotApplicable, 'internal', 'store', IncludeTrailingPathDelimiter(ProgData)+'fhirserver');
            svc.FIni.WriteString('snomed', 'cache', importSnomedRF2(dir, dest, ver, svc.callback));
          end
          else if FindCmdLineSwitch('loinc', dir, true, [clstValueNextParam]) then
          begin
            if not FindCmdLineSwitch('lver', lver, true, [clstValueNextParam]) then
              writeln('LOINC Version parameter needed: -lver X.XX')
            else if not FindCmdLineSwitch('ldate', ldate, true, [clstValueNextParam]) then
              writeln('LOINC Date parameter needed: -ldate MONTH 20XX')
           else
              svc.FIni.WriteString('loinc', 'cache', importLoinc(dir, lver, ldate, svc.FIni.ReadString(voVersioningNotApplicable, 'internal', 'store', IncludeTrailingPathDelimiter(ProgData)+'fhirserver')))
          end
          else if FindCmdLineSwitch('rxstems', dir, true, []) then
          begin
            generateRxStems(TKDBOdbcManager.create('fhir', 100, 0, svc.FIni.ReadString(voMaybeVersioned, 'database', 'driver', ''),
              svc.FIni.ReadString(voVersioningNotApplicable, 'database', 'server', ''), svc.FIni.ReadString(voVersioningNotApplicable, 'RxNorm', 'database', ''),
              svc.FIni.ReadString(voVersioningNotApplicable, 'database', 'username', ''), svc.FIni.ReadString(voVersioningNotApplicable, 'database', 'password', '')))
          end
          else if FindCmdLineSwitch('ncistems', dir, true, []) then
          begin
            generateRxStems(TKDBOdbcManager.create('fhir', 100, 0, svc.FIni.ReadString(voMaybeVersioned, 'database', 'driver', ''),
              svc.FIni.ReadString(voVersioningNotApplicable, 'database', 'server', ''), svc.FIni.ReadString(voVersioningNotApplicable, 'NciMeta', 'database', ''),
              svc.FIni.ReadString(voVersioningNotApplicable, 'database', 'username', ''), svc.FIni.ReadString(voVersioningNotApplicable, 'database', 'password', '')))
          end
      //    procedure ReIndex;
      //    procedure clear(types : String);
          else if FindCmdLineSwitch('unii', fn, true, [clstValueNextParam]) then
          begin
           svc.ConnectToDatabase;
           ImportUnii(fn, svc.Fdb)
          end
          else
          begin
            svc.Execute;
          end;
        finally
          GJsHost.free;
        end;
      finally
        factory.Free;
      end;
    finally
      svc.Free;
    end;
  except
    on e : Exception do
    begin
      if FindCmdLineSwitch('installer') then
        writeln('##> Exception '+E.Message)
      else
        logt(E.ClassName+ ': '+E.Message+#13#10#13#10+ExceptionStack(e));
      raise;
    end;
  end;
end;

{ TFHIRService }

constructor TFHIRService.Create(const ASystemName, ADisplayName, AIniName: String);
begin
  FStartTime := GetTickCount;
  inherited create(ASystemName, ADisplayName);
  FIni := TFHIRServerIniFile.Create(AIniName);
end;

destructor TFHIRService.Destroy;
begin
  CloseDatabase;
  FIni.Free;
  inherited;
end;

function TFHIRService.CanStart: boolean;
begin
  if not DebugMode then
  begin
    filelog := true;
    Consolelog := true;
  end;
  FRunNumber := FIni.ReadInteger(voVersioningNotApplicable, 'server', 'run-number', 0) + 1;
  FIni.WriteInteger('server', 'run-number', FRunNumber);
  logt('Run Number '+inttostr(FRunNumber));

  result := false;
  try
    if FDb = nil then
      ConnectToDatabase;
    if FTerminologyServer = nil then
      LoadTerminologies;
    InitialiseRestServer;
    result := true;
  except
    on e : Exception do
    begin
      logt(E.ClassName+ ': ' + E.Message+#13#10#13#10+ExceptionStack(e));
      raise;
    end;
  end;
  logt('started ('+inttostr((GetTickCount - FStartTime) div 1000)+'secs)');
  log_as_starting := false;
end;

procedure TFHIRService.DoStop;
begin
  try
    logt('stopping: '+StopReason);
    StopRestServer;
    logt('stopping.b: '+StopReason);
    UnloadTerminologies;
    logt('stopping.c: '+StopReason);
  except
    on e : Exception do
      logt(E.ClassName + ': ' + E.Message+#13#10#13#10+ExceptionStack(e));
  end;
    logt('stopping.d: '+StopReason);
end;

procedure TFHIRService.dump;
begin
  inherited;
  logt(KDBManagers.Dump);
end;

function TFHIRService.fetchFromUrl(fn: String; var bytes: TBytes): boolean;
var
  fetch : TInternetFetcher;
begin
  fetch := TInternetFetcher.create;
  try
    fetch.URL := AppendForwardSlash(fn)+'validator.pack';
    try
      fetch.Fetch;
      bytes := fetch.Buffer.AsBytes;
      exit(true);
    except
    end;
    fetch.URL := fn;
    try
      fetch.Fetch;
      bytes := fetch.Buffer.AsBytes;
      exit(true);
    except
      exit(false);
    end;
  finally
    fetch.Free;
  end;
end;

function TFHIRService.RegisterValueSet(id: String; conn : TKDBConnection): integer;
begin
  result := Conn.CountSQL('Select ValueSetKey from ValueSets where URL = '''+SQLWrapString(id)+'''');
  if result = 0 then
  begin
    result := FTerminologyServer.NextValueSetKey;
    Conn.ExecSQL('Insert into ValueSets (ValueSetKey, URL, NeedsIndexing) values ('+inttostr(result)+', '''+SQLWrapString(id)+''', 1)');
  end;
end;


procedure TFHIRService.identifyValueSets;
begin
  logt('Register ValueSets');
  FDb.Connection('register value sets',
    procedure (conn : TKDBConnection)
    var
      vs : TFhirValueSet;
      vsl : TFHIRValueSetList;
    begin
      vsl := FTerminologyServer.GetValueSetList;
      try
        for vs in vsl do
          vs.Tags['tracker'] := inttostr(RegisterValueSet(vs.url, conn));
      finally
        vsl.Free;
      end;
    end);
end;

Procedure TFHIRService.ConnectToDatabase(noCheck : boolean = false);
var
  dbn,ddr : String;
  ver : integer;
  conn : TKDBConnection;
  dbi : TFHIRDatabaseInstaller;
  meta : TKDBMetaData;
begin
  logt('Config file = '+FIni.FileName);
  dbn := FIni.ReadString(voMaybeVersioned, 'database', 'database', '');
  ddr := FIni.ReadString(voMaybeVersioned, 'database', 'driver', 'SQL Server Native Client 11.0');
  if TestMode then
    FDb := TKDBOdbcManager.create('fhir', 100, 0, ddr, '(local)', 'fhir-test', '', '')
  else if FIni.ReadString(voMaybeVersioned, 'database', 'type', '') = 'mssql' then
  begin
    logt('Database mssql://'+FIni.ReadString(voMaybeVersioned, 'database', 'server', '')+'/'+dbn);
    FDb := TKDBOdbcManager.create('fhir', 100, 0, ddr,
      FIni.ReadString(voMaybeVersioned, 'database', 'server', ''), dbn,
      FIni.ReadString(voMaybeVersioned, 'database', 'username', ''), FIni.ReadString(voMaybeVersioned, 'database', 'password', ''));
  end
  else if FIni.ReadString(voMaybeVersioned, 'database', 'type', '') = 'mysql' then
  begin
    logt('Database mysql://'+FIni.ReadString(voMaybeVersioned, 'database', 'server', '')+'/'+dbn);
    FDb := TKDBOdbcManager.create('fhir', 100, 0, ddr,
      FIni.ReadString(voMaybeVersioned, 'database', 'server', ''), dbn,
      FIni.ReadString(voMaybeVersioned, 'database', 'username', ''), FIni.ReadString(voMaybeVersioned, 'database', 'password', ''));
  end
  else if FIni.ReadString(voMaybeVersioned, 'database', 'type', '') = 'SQLite' then
    FDb := TKDBSQLiteManager.create('fhir', dbn, noCheck)
  else
  begin
    logt('Database not configured');
    raise EDBException.create('Database Access not configured');
  end;
  if not noCheck then
  begin
    conn := FDb.GetConnection('check version');
    try
      meta := conn.FetchMetaData;
      try
        if meta.HasTable('Config') then
        begin
          // db version check
          ver := conn.CountSQL('Select Value from Config where ConfigKey = 5');
          if (ver <> ServerDBVersion) then
          begin
            logt('Upgrade Database from version '+inttostr(ver)+' to '+inttostr(ServerDBVersion));
            dbi := TFHIRDatabaseInstaller.create(conn, '');
            try
              dbi.upgrade(ver);
            finally
              dbi.Free;
            end;
          end;
        end;
      finally
        meta.Free;
      end;
      conn.Release;
    except
      on e : Exception do
      begin
        conn.Error(e);
        raise;
      end;
    end;
  end;
end;



function TFHIRService.connectToDB(name: String; max, timeout: integer; driver, server, database, username, password: String; forCreate : boolean): TKDBManager;
begin
  if driver = 'SQLite' then
    result := TKDBSQLiteManager.create(name, database, forCreate)
  else
    result := TKDBOdbcManager.create(name, max, timeout, driver, server, database, username, password);
end;

procedure TFHIRService.cb(i: integer; s: WideString);
begin
  if FInstaller then
    InstallerCallBack(i, s);
end;

procedure TFHIRService.CloseDatabase;
begin
  FDB.Free;
end;

function Locate(s, fn : String; first : boolean) : String;
begin
  result := s;
  if FolderExists(result) then
    if first then
      result := IncludeTrailingPathDelimiter(s)+'examples-json.zip'
    else
      result := IncludeTrailingPathDelimiter(s)+'examples.json.zip';
  if not FileExists(result) then
    result := IncludeTrailingPathDelimiter(ExtractFilePath(fn))+s;
  if not FileExists(result) then
    raise EIOException.create('Unable to find file '+s);
end;

type
  TPackageLoader = class (TFslObject)
  private
    bundle : TFHIRBundle;
    procedure load(rType, id : String; stream : TStream);
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

constructor TPackageLoader.Create;
begin
  inherited;
  bundle := TFHIRBundle.Create;
end;

destructor TPackageLoader.Destroy;
begin
  bundle.Free;
  inherited;
end;

procedure TPackageLoader.load(rType, id : String; stream : TStream);
var
  p : TFHIRParser;
  r : TFHIRResource;
begin
  Logt('  '+inttostr(bundle.entryList.count)+': '+rType+'/'+id);
  p := TFHIRParsers.parser(nil, ffJson, 'en');
  try
    r := p.parseResource(stream) as TFhirResource;
    bundle.entryList.Append.resource := r;
  finally
    p.Free;
  end;
end;

procedure TFHIRService.Load(fn: String);
var
  f : TFileStream;
  st : TStringList;
  s, src, plist, p, pi, pv : String;
  first : boolean;
  ini : TFHIRServerIniFile;
  i : integer;
  bytes : TBytes;
  bs : TBytesStream;
  pl : TArray<String>;
  ploader : TPackageLoader;
  pcm : TFHIRPackageManager;
begin
  FNotServing := true;
  cb(1, 'Load: Connect to database');
  if FDb = nil then
    ConnectToDatabase;
  cb(1, 'Load: start kernel');
  CanStart;
  logt('Load: register value sets');
  identifyValueSets;

  // first we load any packages in the -packages parameter
  if FindCmdLineSwitch('packages', plist, true, [clstValueNextParam]) then
  begin
    pcm := TFHIRPackageManager.Create(false);
    try
      pl := plist.substring(1).Split([',']);
      for p in pl do
      begin
        StringSplit(p, '-', pi, pv);
        if not pcm.packageExists(pi, pv) then
          raise EFHIRException.create('Package '+p+' not found');
        logt('Load Package '+pi+'-'+pv);
        ploader := TPackageLoader.create;
        try
          pcm.loadPackage(pi, pv, ALL_RESOURCE_TYPE_NAMES, ploader.load);
          FWebServer.Transaction(ploader.bundle, true, p, '', callback);
        finally
          ploader.Free;
        end;
      end;
    finally
      pcm.Free;
    end;
  end;

  cb(2, 'Load from '+fn);
  if fn.StartsWith('http://') or fn.StartsWith('https://') then
  begin
    if fetchFromUrl(fn, bytes) then
    begin
      bs := TBytesStream.Create(bytes);
      try
        FWebServer.Transaction(bs, true, fn, '', nil, callback);
      finally
        bs.Free;
      end;
    end
    else
      raise EIOException.create('Unable to fetch from "'+fn+'"');
  end
  else if {$IFDEF FHIR2} true {$ELSE} fn.EndsWith('.json') or fn.EndsWith('.xml') {$ENDIF} then
  begin
    logt('Load database from '+fn);
    f := TFileStream.Create(fn, fmOpenRead + fmShareDenyWrite);
    try
      FWebServer.Transaction(f, true, fn, 'http://hl7.org/fhir', nil, callback);
    finally
      f.Free;
    end
  end
  else
  begin
    if FolderExists(fn) then
      fn := IncludeTrailingPathDelimiter(fn)+'load.ini';
    logt('Load database from sources listed in '+fn);
    if not FileExists(fn) then
      raise EIOException.create('Load Ini file '+fn+' not found');
    ini := TFHIRServerIniFile.Create(fn);
    st := TStringList.Create;
    try
      ini.ReadSection(voMustBeVersioned, 'files', st);
      first := true;
      for s in st do
      begin
        logt('Check file '+s);
        src := locate(s, fn, first);
        first := false;
      end;

      i := 0;
      first := true;
      for s in st do
      begin
        inc(i);
        logt('Load file '+inttostr(i)+' of '+inttostr(st.count)+':'+s);
        cb(0, 'Load from '+s);
        src := locate(s, fn, first);
        f := TFileStream.Create(src, fmOpenRead + fmShareDenyWrite);
        try
          FWebServer.Transaction(f, first, src, ini.ReadString(voMustBeVersioned, 'files', s, ''), nil, callback);
        finally
          f.Free;
        end;
        first := false;
      end;
    finally
      st.Free;
      ini.Free;
    end;
  end;

  logt('done');
  cb(95, 'Building Terminology Closure Tables');
  FTerminologyServer.BuildIndexes(not assigned(callback));
  cb(100, 'Cleaning up');

  DoStop;
end;

procedure TFHIRService.LoadbyProfile(fn: String; init : boolean);
var
  ini : TFHIRServerIniFile;
  f : TFileStream;
  i : integer;
begin
  FNotServing := true;
  ini := TFHIRServerIniFile.Create(fn);
  try
    fn := fn.Replace('.dstu', '');
    if FDb = nil then
      ConnectToDatabase;
    CanStart;
    if init then
    begin
      fn := ini.ReadString(voVersioningNotApplicable, 'control', 'load', '');
      logt('Load database from '+fn);
      f := TFileStream.Create(fn, fmOpenRead + fmShareDenyWrite);
      try
        FWebServer.Transaction(f, true, fn, 'http://hl7.org/fhir', ini, callback);
      finally
        f.Free;
      end;
    end;
    for i := 1 to ini.ReadInteger(voVersioningNotApplicable, 'control', 'files', 0) do
    begin
      fn := ini.ReadString(voVersioningNotApplicable, 'control', 'file'+inttostr(i), '');
      if (fn <> '') then
      begin
        repeat
          logt('Load '+fn);
          f := TFileStream.Create(fn, fmOpenRead + fmShareDenyWrite);
          try
            FWebServer.Transaction(f, false, fn, ini.ReadString(voVersioningNotApplicable, 'control', 'base'+inttostr(i), ''), ini, callback);
          finally
            f.Free;
          end;
        until ini.ReadInteger(voVersioningNotApplicable, 'process', 'start', -1) = -1;
      end;
    end;
    logt('done');
    FTerminologyServer.BuildIndexes(true);
    DoStop;
  finally
    ini.free;
  end;
end;

procedure TFHIRService.LoadTerminologies;
begin
  FTerminologyServer := TTerminologyServer.create(FDB.Link);
  FTerminologyServer.OnConnectDB := connectToDB;
  FTerminologyServer.load(FIni);
end;

function TFHIRService.makeFactory: TFHIRFactory;
begin
  {$IFDEF FHIR2} result := TFHIRFactoryR2.Create; {$ENDIF}
  {$IFDEF FHIR3} result := TFHIRFactoryR3.Create; {$ENDIF}
  {$IFDEF FHIR4} result := TFHIRFactoryR4.Create; {$ENDIF}
end;

procedure TFHIRService.postStart;
begin
end;

procedure TFHIRService.UnloadTerminologies;
begin
  FTerminologyServer.Free;
  FTerminologyServer := nil;
end;

procedure TFHIRService.Index;
begin
  FNotServing := true;
  if FDb = nil then
    ConnectToDatabase;
  CanStart;
  logt('index database');
  FTerminologyServer.BuildIndexes(true);
  DoStop;
end;

procedure TFHIRService.validate;
begin
  FNotServing := true;
  if FDb = nil then
    ConnectToDatabase;
  CanStart;
  logt('validate resources');
  FWebServer.ServerContext.Storage.RunValidation;
  DoStop;
end;

procedure TFHIRService.InitialiseRestServer;
var
  ctxt : TFHIRServerContext;
  store : TFHIRServerDataStore;
  jp : String;
begin
  store := TFHIRServerDataStore.create(FDB.Link, ProcessPath(ExtractFilePath(Fini.FileName), FIni.ReadString(voVersioningNotApplicable, 'fhir', 'web', '')));
  try
    ctxt := TFHIRServerContext.Create(store.Link);
    try
      store.ServerContext := ctxt;
      ctxt.Factory := makeFactory;
      ctxt.RunNumber := FRunNumber;
      ctxt.TerminologyServer := FterminologyServer.Link;
      ctxt.Validate := FIni.ReadBool(voVersioningNotApplicable, 'fhir', 'validate', true);
      ctxt.ForLoad := not FindCmdLineSwitch('noload');
      ctxt.ownername := Fini.readString(voVersioningNotApplicable, 'admin', 'ownername', '');
      store.Initialise(FIni);
      FWebServer := TFhirWebServer.create(FIni.link, DisplayName, FTerminologyServer, ctxt.link);
      ctxt.userProvider := TSCIMServer.Create(Fdb.link, FIni.ReadString(voVersioningNotApplicable, 'scim', 'salt', ''), FWebServer.host, FIni.ReadString(voVersioningNotApplicable, 'scim', 'default-rights', ''), false);
      ctxt.userProvider.OnProcessFile := FWebServer.ReturnProcessedFile;
      FWebServer.SourceProvider := TFHIRWebServerSourceFolderProvider.Create(ProcessPath(ExtractFilePath(FIni.FileName), FIni.ReadString(voVersioningNotApplicable, 'fhir', 'web', '')));
      FWebServer.AuthServer.UserProvider := ctxt.userProvider.Link;
      FWebServer.CDSHooksServer.registerService(TCDAHooksCodeViewService.create);
      FWebServer.CDSHooksServer.registerService(TCDAHooksIdentifierViewService.create);
      FWebServer.CDSHooksServer.registerService(TCDAHooksPatientViewService.create);
      FWebServer.CDSHooksServer.registerService(TCDAHackingHealthOrderService.create);

      FWebServer.Start(not FNotServing);
    finally
      ctxt.free;
    end;
  finally
    store.free;
  end;
end;

procedure TFHIRService.InstallDatabase;
var
  db : TFHIRDatabaseInstaller;
  scim : TSCIMServer;
  salt, un, pw, em, sql, dr : String;
  conn : TKDBConnection;

begin
  // check that user account details are provided
  salt := FIni.ReadString(voVersioningNotApplicable, 'scim', 'salt', '');
  if (salt = '') then
    raise EFHIRException.create('You must define a scim salt in the ini file');
  dr := FIni.ReadString(voVersioningNotApplicable, 'scim', 'default-rights', '');
  if (dr = '') then
    raise EFHIRException.create('You must define some default rights for SCIM users in the ini file');
  un := FIni.ReadString(voVersioningNotApplicable, 'admin', 'username', '');
  if (un = '') then
    raise EFHIRException.create('You must define an admin username in the ini file');
  FindCmdLineSwitch('password', pw, true, [clstValueNextParam]);
  if (pw = '') then
    raise EFHIRException.create('You must provide a admin password as a parameter to the command');
  em := FIni.ReadString(voVersioningNotApplicable, 'admin', 'email', '');
  if (em = '') then
    raise EFHIRException.create('You must define an admin email in the ini file');

  sql := 'C:\work\fhirserver\sql';
  if not DirectoryExists(sql) then
    sql := IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0)))+'sql';


  if FDb = nil then
    ConnectToDatabase(true);
  logt('mount database');
  scim := TSCIMServer.Create(FDB.Link, salt, FIni.ReadString(voVersioningNotApplicable, 'web', 'host', ''), FIni.ReadString(voVersioningNotApplicable, 'scim', 'default-rights', ''), true);
  try
    conn := FDb.GetConnection('setup');
    try
      db := TFHIRDatabaseInstaller.create(conn, sql);
      try
        db.callback := callback;
        db.Bases.Add('http://healthintersections.com.au/fhir/argonaut');
        db.Bases.Add('http://hl7.org/fhir');
        db.Install(scim);
      finally
        db.free;
      end;
      scim.DefineAnonymousUser(conn);
      scim.DefineAdminUser(conn, un, pw, em);
      conn.Release;
      logt('done');
    except
       on e:exception do
       begin
         logt('Error: '+e.Message);
         conn.Error(e);
         recordStack(e);
         raise;
       end;
    end;
  finally
    scim.Free;
  end;
end;

procedure TFHIRService.InstallerCallBack(i: integer; s: String);
begin
  writeln('##> '+inttostr(i)+' '+s);
end;

procedure TFHIRService.UnInstallDatabase;
var
  db : TFHIRDatabaseInstaller;
  conn : TKDBConnection;
begin
  if FDb = nil then
    ConnectToDatabase(true);
  logt('unmount database');
  conn := FDb.GetConnection('setup');
  try
    db := TFHIRDatabaseInstaller.create(conn, '');
    try
      db.callback := callback;
      db.UnInstall;
    finally
      db.free;
    end;
    conn.Release;
    logt('done');
  except
     on e:exception do
     begin
       logt('Error: '+e.Message);
       conn.Error(e);
       recordStack(e);
       raise;
     end;
  end;
end;

procedure TFHIRService.StopRestServer;
begin
  FWebServer.Stop;
  FWebServer.free;
end;

{ TFHIRServerDataStore }

function TFHIRServerDataStore.createOperationContext(lang: String): TFHIROperationEngine;
begin
  result := TFHIRNativeOperationEngine.Create(lang, ServerContext, self.Link, DB.GetConnection('Operation'));
end;

procedure TFHIRServerDataStore.Yield(op: TFHIROperationEngine; e : Exception);
begin
  try
    if e = nil then
      TFHIRNativeOperationEngine(op).Connection.Release
    else
      TFHIRNativeOperationEngine(op).Connection.Error(e);
  finally
    op.Free;
  end;
end;


end.


unit FHIR.Server.Storage;

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


interface

uses
  SysUtils, Classes, System.Generics.Collections,
  FHIR.Support.Lock, FHIR.Support.Strings, FHIR.Support.System, FHIR.Support.Text, FHIR.Web.Parsers,
  FHIR.Support.Objects, FHIR.Support.Generics,  FHIR.Support.Exceptions, FHIR.Support.Collections, FHIR.Support.Stream,
  FHIR.Database.Dialects, FHIR.Support.DateTime, FHIR.Misc.GraphQL,

  FHIR.Base.Objects, FHIR.Server.Session, FHIR.Version.Types, FHIR.Version.Resources, FHIR.Version.Constants, FHIR.Version.Utilities, FHIR.Base.Lang, FHIR.Base.Common,
  FHIR.Client.Base, FHIR.Version.Common,
  FHIR.Version.Client, FHIR.Version.Context, FHIR.Base.Xhtml, FHIR.Version.IndexInfo, FHIR.Base.Parser, FHIR.Tools.Indexing, FHIR.Tools.GraphQL, FHIR.Server.XhtmlComp,
  FHIR.CdsHooks.Utilities,
  FHIR.Server.Validator, FHIR.Server.Subscriptions, FHIR.Server.Utilities, FHIR.Server.Constants, FHIR.Server.Indexing;


Type
  TAsyncTaskStatus = (atsCreated, atsWaiting, atsProcessing, atsComplete, atsAborted, atsTerminated, atsError, atsDeleted);

  TPopulateConformanceEvent = procedure (sender : TObject; conf : TFhirCapabilityStatement) of object;

  TFHIRStorageService = class;
  TFHIROperationEngine = class;

  TOperationContext = class (TFslObject)
  private
    FUpload : boolean;
    FCallback : TInstallerCallback;
    FMessage : String;
    FMessageDetail: String;
  public
    constructor Create; overload; override;
    constructor Create(upload : boolean; callback : TInstallerCallback; message : String); overload;

    property upload : boolean read FUpload write FUpload;
    property callback : TInstallerCallback read FCallback write FCallback;
    property message : String read FMessage write FMessage;
    property MessageDetail : String read FMessageDetail write FMessageDetail;

    procedure progress(i : integer);
  end;

  TFhirOperation = class abstract (TFslObject)
  protected
    function resolvePatient(manager: TFHIROperationEngine; request: TFHIRRequest; ref : String) : integer;
    function CreateBaseDefinition(base : String) : TFHIROperationDefinition;
    function isWrite : boolean; virtual;
    function owningResource : TFhirResourceType; virtual; // for security purposes
    function makeParams(request : TFHIRRequest) : TFhirParameters;

  public
    function Name : String; virtual;
    function Types : TFhirResourceTypeSet; virtual;
    function HandlesRequest(request : TFHIRRequest) : boolean; virtual;
    function CreateDefinition(base : String) : TFHIROperationDefinition; virtual;
    procedure Execute(context : TOperationContext; manager: TFHIROperationEngine; request: TFHIRRequest; response : TFHIRResponse); virtual;
    function formalURL : String; virtual;
  end;

  TMatchingResource = class (TFslName)
  public
    key : integer;
    version : integer;
  end;

  TMatchingResourceList = class (TFslNameList)
  private
    function GetEntry(iIndex: Integer): TMatchingResource;
  public
    Property entries[iIndex : Integer] : TMatchingResource Read GetEntry; Default;
  end;

  TAsyncTaskInformation = class (TFslObject)
  private
    FKey: integer;
    FNames: TArray<String>;
    FFormat: TFHIRFormat;
  public
    function link : TAsyncTaskInformation; overload;
    property key : integer read FKey write FKey;
    property names : TArray<String> read FNames write FNames;
    property format : TFHIRFormat read FFormat write FFormat;
  end;

  TRegisteredClientMode = (rcmOAuthClient, rcmBackendServices);

  TRegisteredClientInformation = class (TFslObject)
  private
    FRedirects: TStringList;
    FMode: TRegisteredClientMode;
    FName: String;
    FJwt: String;
    FPublicKey: String;
    FSecret: string;
    FsoftwareVersion: String;
    Flogo: String;
    Furl: String;
    FsoftwareId: String;
    FIssuer: String;
    FPatientContext: boolean;
  public
    constructor Create; override;
    destructor Destroy; override;

    function link : TRegisteredClientInformation; overload;

    property name : String read FName write FName;
    property jwt : String read FJwt write FJwt; // for application verification service
    property mode : TRegisteredClientMode read FMode write FMode;
    property secret : string read FSecret write FSecret;
    Property redirects : TStringList read FRedirects;
    property publicKey : String read FPublicKey write FPublicKey;
    property issuer : String read FIssuer write FIssuer;
    property url : String read Furl write Furl;
    property logo : String read Flogo write Flogo;
    property softwareId : String read FsoftwareId write FsoftwareId;
    property softwareVersion : String read FsoftwareVersion write FsoftwareVersion;
    property patientContext : boolean read FPatientContext write FPatientContext;
  end;

  TFindResourceOption = (froFindDeletedResource, froForCommit);

  TFindResourceOptions = set of TFindResourceOption;

  TFHIROperationEngine = class (TFslObject)
  private
    FOnPopulateConformance : TPopulateConformanceEvent;
    FLang : String;
    procedure AddCDSHooks(conf : TFhirCapabilityStatementRest);
    procedure addParam(srch : TFhirCapabilityStatementRestResourceSearchParamList; html : TFslStringBuilder; n, url, d : String; t : TFhirSearchParamTypeEnum; tgts : Array of String);
  protected
    FServerContext : TFslObject;
    FOperations : TFslList<TFhirOperation>;
    procedure processGraphQL(graphql: String; request : TFHIRRequest; response : TFHIRResponse); virtual; abstract;

    procedure StartTransaction; virtual; abstract;
    procedure CommitTransaction; virtual; abstract;
    procedure RollbackTransaction; virtual; abstract;

    function ExecuteRead(request: TFHIRRequest; response : TFHIRResponse; ignoreHeaders : boolean) : boolean; virtual;
    function  ExecuteUpdate(context : TOperationContext; request: TFHIRRequest; response : TFHIRResponse) : Boolean; virtual;
    function  ExecutePatch(request: TFHIRRequest; response : TFHIRResponse) : Boolean; virtual;
    procedure ExecuteVersionRead(request: TFHIRRequest; response : TFHIRResponse); virtual;
    procedure ExecuteDelete(request: TFHIRRequest; response : TFHIRResponse); virtual;
    procedure ExecuteHistory(request: TFHIRRequest; response : TFHIRResponse); virtual;
    procedure ExecuteSearch(request: TFHIRRequest; response : TFHIRResponse); virtual;
    Function  ExecuteCreate(context : TOperationContext; request: TFHIRRequest; response : TFHIRResponse; idState : TCreateIdState; iAssignedKey : Integer) : String; virtual;
    procedure ExecuteConformanceStmt(request: TFHIRRequest; response : TFHIRResponse); virtual;
    procedure ExecuteUpload(context : TOperationContext; request: TFHIRRequest; response : TFHIRResponse); virtual;
    function  ExecuteValidation(request: TFHIRRequest; response : TFHIRResponse; opDesc : String) : boolean; virtual;
    procedure ExecuteTransaction(context : TOperationContext; request: TFHIRRequest; response : TFHIRResponse); virtual;
    procedure ExecuteBatch(context : TOperationContext; request: TFHIRRequest; response : TFHIRResponse); virtual;
    procedure ExecuteOperation(context : TOperationContext; request: TFHIRRequest; response : TFHIRResponse); virtual;
    procedure BuildSearchForm(request: TFHIRRequest; response: TFHIRResponse);
  public
    constructor create(ServerContext : TFslObject; lang : String);
    destructor Destroy; override;

    procedure NoMatch(request: TFHIRRequest; response: TFHIRResponse);
    procedure NotFound(request: TFHIRRequest; response : TFHIRResponse);
    procedure VersionNotFound(request: TFHIRRequest; response : TFHIRResponse);
    procedure TypeNotFound(request: TFHIRRequest; response : TFHIRResponse);

    Property OnPopulateConformance : TPopulateConformanceEvent read FOnPopulateConformance write FOnPopulateConformance;
    property lang : String read FLang write FLang;

    function opAllowed(resource : string; command : TFHIRCommandType) : Boolean; virtual;
    function check(response : TFHIRResponse; test : boolean; code : Integer; lang, message : String; issueCode : TExceptionType) : Boolean; virtual;
    Function Execute(context : TOperationContext; request: TFHIRRequest; response : TFHIRResponse) : String;  virtual;
    function LookupReference(context : TFHIRRequest; id : String) : TResourceWithReference; virtual; abstract;
    function getResourcesByParam(aType : TFhirResourceType; name, value : string; var needSecure : boolean): TFslList<TFHIRResource>; virtual;
    function FindResource(aType, sId : String; options : TFindResourceOptions; var resourceKey, versionKey : integer; request: TFHIRRequest; response: TFHIRResponse; sessionCompartments : TFslList<TFHIRCompartmentId>): boolean; virtual;
    function GetResourceById(request: TFHIRRequest; aType : String; id, base : String; var needSecure : boolean) : TFHIRResource; virtual; abstract;
    function getResourceByUrl(aType : TFhirResourceType; url, version : string; allowNil : boolean; var needSecure : boolean): TFHIRResource; virtual; abstract;
    function GetResourceByKey(key : integer; var needSecure : boolean): TFHIRResource; virtual;
    function ResolveSearchId(resourceName : String; requestCompartment : TFHIRCompartmentId; SessionCompartments : TFslList<TFHIRCompartmentId>; baseURL, params : String) : TMatchingResourceList; virtual;
    procedure AuditRest(session : TFhirSession; intreqid, extreqid, ip, resourceName : string; id, ver : String; verkey : integer; op : TFHIRCommandType; provenance : TFhirProvenance; httpCode : Integer; name, message : String); overload; virtual; abstract;
    procedure AuditRest(session : TFhirSession; intreqid, extreqid, ip, resourceName : string; id, ver : String; verkey : integer; op : TFHIRCommandType; provenance : TFhirProvenance; opName : String; httpCode : Integer; name, message : String); overload; virtual; abstract;

    function createClient(lang : String; session: TFHIRSession) : TFHIRClient; virtual;
  end;

  TFHIRInternalCommunicator = class (TFHIRClientCommunicator)
  private
    FServerContext : TFslObject;
    FEngine : TFHIROperationEngine;
    FContext: TFHIRWorkerContext;
    FSession: TFHIRSession;
    procedure SetContext(const Value: TFHIRWorkerContext);
    procedure SetSession(const Value: TFHIRSession);
    procedure doGetBundleBuilder(request: TFHIRRequest; context: TFHIRResponse; aType: TFhirBundleTypeEnum; out builder: TFhirBundleBuilder);
  public
    Destructor Destroy; override;
    function link : TFHIRInternalCommunicator; overload;

    property Session : TFHIRSession read FSession write SetSession;
    property Context : TFHIRWorkerContext read FContext write SetContext;

    function address : String; override;

    function conformanceV(summary : boolean) : TFHIRResourceV; override;
    function transactionV(bundle : TFHIRResourceV) : TFHIRResourceV; override;
    function createResourceV(resource : TFHIRResourceV; var id : String) : TFHIRResourceV; override;
    function readResourceV(atype : TFhirResourceTypeV; id : String) : TFHIRResourceV; override;
    function updateResourceV(resource : TFHIRResourceV) : TFHIRResourceV; overload; override;
    procedure deleteResourceV(atype : TFHIRResourceTypeV; id : String); override;
    function searchV(atype : TFHIRResourceTypeV; allRecords : boolean; params : string) : TFHIRResourceV; overload; override;
    function searchPostV(atype : TFHIRResourceTypeV; allRecords : boolean; params : TStringList; resource : TFHIRResourceV) : TFHIRResourceV; override;
    function searchAgainV(link : String) : TFHIRResourceV; overload; override;
    function operationV(atype : TFHIRResourceTypeV; opName : String; params : TFHIRResourceV) : TFHIRResourceV; overload; override;
    function operationV(atype : TFHIRResourceTypeV; id, opName : String; params : TFHIRResourceV) : TFHIRResourceV; overload; override;
    function historyTypeV(atype : TFHIRResourceTypeV; allRecords : boolean; params : string) : TFHIRResourceV; override;
    function customGet(path : String; headers : THTTPHeaders) : TFslBuffer; override;
    function customPost(path : String; headers : THTTPHeaders; body : TFslBuffer) : TFslBuffer; override;
    procedure terminate; override;
  end;

  TFHIRStorageService = class (TFslObject)
  protected
    function GetTotalResourceCount: integer; virtual; abstract;
  public
    Constructor Create; override;
    Destructor Destroy; override;
    function Link : TFHIRStorageService; overload;

    // OAuth Support
    procedure recordOAuthLogin(id, client_id, scope, redirect_uri, state : String); virtual;
    function fetchOAuthDetails(key, status : integer; var client_id, name, redirect, state, scope : String) : boolean; virtual;
    procedure recordOAuthChoice(id : String; scopes, jwt, patient : String); virtual;
    function hasOAuthSession(id : String; status : integer) : boolean; virtual;
    function hasOAuthSessionByKey(key, status : integer) : boolean; virtual;
    procedure updateOAuthSession(id : String; state, key : integer; var client_id : String); virtual;
    procedure RegisterConsentRecord(session: TFhirSession); virtual;
    function FetchAuthorization(hash : String; var PatientId : String; var ConsentKey, SessionKey : Integer; var Expiry : TDateTime; var jwt : String) : boolean; virtual;

    // server total counts:
    function FetchResourceCounts(compList : TFslList<TFHIRCompartmentId>) : TStringList; virtual;  abstract;// comps = comma delimited list of patient compartments
    Property TotalResourceCount: integer read GetTotalResourceCount;


    procedure Sweep; virtual; abstract;
    procedure RecordFhirSession(session: TFhirSession); virtual; abstract;
    procedure CloseFhirSession(key: integer); virtual; abstract;
    procedure QueueResource(r: TFhirResource); overload; virtual; abstract;
    procedure QueueResource(r: TFhirResource; dateTime: TDateTimeEx); overload; virtual; abstract;
    procedure RegisterAuditEvent(session: TFhirSession; ip: String); virtual; abstract;
    function RetrieveSession(key : integer; var UserKey, Provider : integer; var Id, Name, Email : String) : boolean; virtual; abstract;

    function ProfilesAsOptionList : String; virtual; abstract;

    procedure ProcessSubscriptions; virtual; abstract;
    procedure ProcessEmails; virtual; abstract;
    procedure ProcessObservations; virtual; abstract;
    procedure RunValidation; virtual; abstract;


    function createOperationContext(lang : String) : TFHIROperationEngine; virtual; abstract;
    Procedure Yield(op : TFHIROperationEngine; exception : Exception); overload; virtual; abstract;
    function createClient(lang : String; ServerContext : TFslObject; context: TFHIRWorkerContext; session: TFHIRSession) : TFHIRClient; virtual;
    Procedure Yield(client : TFHIRClient; exception : Exception); overload; virtual;
    function ExpandVS(vs: TFHIRValueSet; ref: TFhirReference; lang : String; limit, count, offset: integer; allowIncomplete: Boolean; dependencies: TStringList): TFHIRValueSet; virtual;
    function LookupCode(system, version, code: String): String; virtual;
    function FetchResource(key : integer) : TFHIRResource; virtual; abstract;

    function createAsyncTask(url, id : string; format : TFHIRFormat; secure : boolean) : integer; virtual;
    procedure setAsyncTaskDetails(key : integer; transactionTime : TDateTimeEx; request : String); virtual;
    procedure updateAsyncTaskStatus(key : integer; status : TAsyncTaskStatus; message : String); virtual;
    procedure MarkTaskForDownload(key : integer; names : TStringList); virtual;
    function fetchTaskDetails(id : String; var key : integer; var status : TAsyncTaskStatus; var fmt : TFHIRFormat; var secure : boolean; var message, originalRequest : String; var transactionTime, expires : TDateTimeEx; names : TStringList; var outcome : TBytes): boolean; virtual;
    procedure recordDownload(key : integer; name : String); virtual;
    procedure fetchExpiredTasks(tasks : TFslList<TAsyncTaskInformation>); virtual;
    procedure MarkTaskDeleted(key : integer); virtual;

    function getClientInfo(id : String) : TRegisteredClientInformation; virtual; abstract;
    function getClientName(id : String) : string; virtual; abstract;
    function storeClient(client : TRegisteredClientInformation; sessionKey : integer) : String; virtual; abstract;
    procedure fetchClients(list : TFslList<TRegisteredClientInformation>); virtual; abstract;
  end;


implementation

uses
  FHIR.Server.Context;

{ TFHIRStorageService }

constructor TFHIRStorageService.Create;
begin
  inherited;
end;

destructor TFHIRStorageService.Destroy;
begin
  inherited;
end;

function TFHIRStorageService.ExpandVS(vs: TFHIRValueSet; ref: TFhirReference; lang : String; limit, count, offset: integer; allowIncomplete: Boolean; dependencies: TStringList): TFHIRValueSet;
begin
  raise EFHIRException.create('Expanding valuesets is not implemented in this server');
end;


function TFHIRStorageService.FetchAuthorization(hash: string; var PatientId : string; var ConsentKey, SessionKey: Integer; var Expiry: TDateTime; var jwt: String): boolean;
begin
  raise EFHIRException.create('This server does not support OAuth');
end;

procedure TFHIRStorageService.fetchExpiredTasks(tasks: TFslList<TAsyncTaskInformation>);
begin
  raise EFHIRException.create('This server does not support Async tasks');
end;

function TFHIRStorageService.fetchOAuthDetails(key, status: integer; var client_id, name, redirect, state, scope: String): boolean;
begin
  raise EFHIRException.create('This server does not support OAuth');
end;

function TFHIRStorageService.fetchTaskDetails(id : String; var key : integer; var status: TAsyncTaskStatus; var fmt : TFHIRFormat; var secure : boolean; var message, originalRequest: String; var transactionTime, expires: TDateTimeEx; names : TStringList; var outcome: TBytes): boolean;
begin
  raise EFHIRException.create('This server does not support Async tasks');
end;

function TFHIRStorageService.hasOAuthSession(id: String; status : integer): boolean;
begin
  raise EFHIRException.create('This server does not support OAuth');
end;

function TFHIRStorageService.hasOAuthSessionByKey(key, status: integer): boolean;
begin
  raise EFHIRException.create('This server does not support OAuth');
end;

function TFHIRStorageService.Link: TFHIRStorageService;
begin
  result := TFHIRStorageService(inherited Link);
end;

function TFHIRStorageService.LookupCode(system, version, code: String): String;
begin
  raise EFHIRException.create('Looking up codes is not implemented in this server');
end;

procedure TFHIRStorageService.MarkTaskDeleted(key: integer);
begin
  raise EFHIRException.create('This server does not support Async tasks');
end;

procedure TFHIRStorageService.MarkTaskForDownload(key: integer; names : TStringList);
begin
  raise EFHIRException.create('This server does not support Async tasks');
end;

procedure TFHIRStorageService.recordDownload(key: integer; name: String);
begin
  raise EFHIRException.create('This server does not support Async tasks');
end;

procedure TFHIRStorageService.recordOAuthChoice(id, scopes, jwt, patient: String);
begin
  raise EFHIRException.create('This server does not support OAuth');
end;

procedure TFHIRStorageService.recordOAuthLogin(id, client_id, scope, redirect_uri, state: String);
begin
  raise EFHIRException.create('This server does not support OAuth');
end;

procedure TFHIRStorageService.RegisterConsentRecord(session: TFhirSession);
begin
  raise EFHIRException.create('This server does not support OAuth');
end;

procedure TFHIRStorageService.setAsyncTaskDetails(key: integer; transactionTime: TDateTimeEx; request: String);
begin
  raise EFHIRException.create('This server does not support Async tasks');
end;

procedure TFHIRStorageService.updateAsyncTaskStatus(key: integer; status: TAsyncTaskStatus; message: String);
begin
  raise EFHIRException.create('This server does not support Async tasks');
end;

procedure TFHIRStorageService.updateOAuthSession(id : String; state, key: integer; var client_id : String);
begin
  raise EFHIRException.create('This server does not support OAuth');
end;

{ TFHIROperationEngine }


{ TOperationContext }

constructor TOperationContext.Create;
begin
  inherited Create;
end;

constructor TOperationContext.Create(upload: boolean; callback: TInstallerCallback; message : String);
begin
  Create;
  FUpload := upload;
  FCallback := callback;
  FMessage := message;
end;

procedure TOperationContext.progress(i: integer);
begin
  if assigned(FCallback) then
    if MessageDetail <> '' then
      FCallback(i, FMessage+' '+MessageDetail)
    else
      FCallback(i, FMessage)
end;


{ TFHIROperationEngine }

constructor TFHIROperationEngine.create(ServerContext : TFslObject; lang: String);
begin
  inherited create;
  FServerContext := ServerContext;
  FLang := lang;
  FOperations := TFslList<TFhirOperation>.create;
end;

function TFHIROperationEngine.createClient(lang: String; session: TFHIRSession): TFHIRClient;
var
  int : TFHIRInternalCommunicator;
begin
  int := TFHIRInternalCommunicator.Create;
  try
    int.FServerContext := FServerContext.Link;
    int.FEngine := self.link as TFHIROperationEngine;
    int.Context := TFHIRServerContext(FServerContext).ValidatorContext.link;
    int.session := session.link;
    result := TFHIRClient.Create(TFHIRServerContext(FServerContext).ValidatorContext.link, lang, int.Link);
  finally
    int.Free;
  end;
end;

destructor TFHIROperationEngine.Destroy;
begin
  FOperations.Free;
  inherited;
end;

procedure TFHIROperationEngine.NoMatch(request: TFHIRRequest; response: TFHIRResponse);
begin
  response.HTTPCode := 404;
  response.Message := StringFormat(GetFhirMessage('MSG_NO_MATCH', lang), [request.ResourceName+'?'+request.parameters.source]);
  response.Body := response.Message;
  response.Resource := BuildOperationOutcome(lang, response.Message);
end;

procedure TFHIROperationEngine.NotFound(request: TFHIRRequest; response: TFHIRResponse);
begin
  response.HTTPCode := 404;
  response.Message := StringFormat(GetFhirMessage('MSG_NO_EXIST', lang), [request.ResourceName+':'+request.Id]);
  response.Body := response.Message;
  response.Resource := BuildOperationOutcome(lang, response.Message);
end;

function TFHIROperationEngine.opAllowed(resource: string; command: TFHIRCommandType): Boolean;
begin
  result := true;
end;

procedure TFHIROperationEngine.VersionNotFound(request: TFHIRRequest; response: TFHIRResponse);
begin
  response.HTTPCode := 404;
  response.Message := StringFormat(GetFhirMessage('MSG_NO_EXIST', lang), [request.ResourceName+':'+request.Id+'/_history/'+request.subId]);
  response.Body := response.Message;
  response.Resource := BuildOperationOutcome(lang, response.Message);
end;


procedure TFHIROperationEngine.TypeNotFound(request: TFHIRRequest; response: TFHIRResponse);
begin
  response.HTTPCode := 404;
  response.Message := StringFormat(GetFhirMessage('MSG_UNKNOWN_TYPE', lang), [request.ResourceName]);
  response.Body := response.Message;
  response.Resource := BuildOperationOutcome(lang, response.Message);
end;

function TFHIROperationEngine.check(response: TFHIRResponse; test: boolean; code : Integer; lang, message: String; issueCode : TExceptionType): Boolean;
begin
  result := test;
  if not test and (response <> nil) then
  begin
    response.HTTPCode := code;
    response.Message := message;
    response.ContentType := 'text/plain';
    response.Body := message;
    response.Resource := BuildOperationOutcome(lang, message, ExceptionTypeTranslations[issueCode]);
  end;
end;



function TFHIROperationEngine.Execute(context: TOperationContext; request: TFHIRRequest; response: TFHIRResponse): String;
begin
  StartTransaction;
  try
    result := Request.Id;
    case request.CommandType of
      fcmdRead : ExecuteRead(request, response, false);
      fcmdUpdate : ExecuteUpdate(context, request, response);
      fcmdVersionRead : ExecuteVersionRead(request, response);
      fcmdDelete : ExecuteDelete(request, response);
      fcmdHistoryInstance, fcmdHistoryType, fcmdHistorySystem : ExecuteHistory(request, response);
      fcmdSearch : ExecuteSearch(request, response);
      fcmdCreate : result := ExecuteCreate(context, request, response, request.NewIdStatus, 0);
      fcmdConformanceStmt : ExecuteConformanceStmt(request, response);
      fcmdTransaction : ExecuteTransaction(context, request, response);
      fcmdBatch : ExecuteBatch(context, request, response);
      fcmdOperation : ExecuteOperation(context, request, response);
      fcmdUpload : ExecuteUpload(context, request, response);
      fcmdPatch : ExecutePatch(request, response);
      fcmdValidate : ExecuteValidation(request, response, 'Validation')
    else
      raise EFHIRException.create(GetFhirMessage('MSG_UNKNOWN_OPERATION', lang));
    End;

    CommitTransaction;
  except
    on e:exception do
    begin
      RollbackTransaction;
      raise;
    end;
  end;
end;

procedure TFHIROperationEngine.ExecuteBatch(context: TOperationContext; request: TFHIRRequest; response: TFHIRResponse);
begin
  raise EFHIRException.create('This server does not implement the "Batch" function');
end;

procedure TFHIROperationEngine.ExecuteConformanceStmt(request: TFHIRRequest; response: TFHIRResponse);
var
  oConf : TFhirCapabilityStatement;
  res : TFhirCapabilityStatementRestResource;
  a : String;
  html : TFslStringBuilder;
  c : TFhirContactPoint;
  i : integer;
  op : TFhirCapabilityStatementRestOperation;
  ct : TFhirConformanceContact;
  ServerContext : TFHIRServerContext;
begin
  ServerContext := TFHIRServerContext(FServerContext);
  try

    response.HTTPCode := 200;
    oConf := TFhirCapabilityStatement.Create;
    response.Resource := oConf;

    oConf.id := 'FhirServer';
    ct := oConf.contactList.Append;
    c := ct.telecomList.Append;
    c.system := ContactPointSystemOther;
    c.value := 'http://healthintersections.com.au/';
    if ServerContext.FormalURLPlain <> '' then
      oConf.url := AppendForwardSlash(ServerContext.FormalURLPlainOpen)+'metadata'
    else
      oConf.url := 'http://fhir.healthintersections.com.au/open/metadata';

    oConf.version := FHIR_GENERATED_VERSION+'-'+SERVER_VERSION; // this conformance statement is versioned by both
    oConf.name := 'Health Intersections FHIR Server Conformance Statement';
    oConf.publisher := 'Health Intersections'; //
    oConf.description := 'Standard Conformance Statement for the open source Reference FHIR Server provided by Health Intersections';
    oConf.status := PublicationStatusActive;
    oConf.experimental := false;
    oConf.date := TDateTimeEx.makeUTC;
    oConf.software := TFhirCapabilityStatementSoftware.Create;
    oConf.software.name := 'Reference Server';
    oConf.software.version := SERVER_VERSION;
    oConf.software.releaseDate := TDateTimeEx.fromXml(SERVER_RELEASE_DATE);
    if ServerContext.FormalURLPlainOpen <> '' then
    begin
      oConf.implementation_ := TFhirCapabilityStatementImplementation.Create;
      oConf.implementation_.description := 'FHIR Server running at '+ServerContext.FormalURLPlainOpen;
      oConf.implementation_.url := ServerContext.FormalURLPlainOpen;
    end;
    if assigned(OnPopulateConformance) then
      OnPopulateConformance(self, oConf);
    {$IFNDEF FHIR4}
    oConf.acceptUnknown := UnknownContentCodeBoth;
    {$ENDIF}
    {$IFNDEF FHIR2}
    oConf.formatList.Append.value := 'application/fhir+xml';
    oConf.formatList.Append.value := 'application/fhir+json';
    {$ELSE}
    oConf.formatList.Append.value := 'application/xml+fhir';
    oConf.formatList.Append.value := 'application/json+fhir';
    {$ENDIF}

    oConf.fhirVersion := FHIR_GENERATED_VERSION;
    oConf.restList.add(TFhirCapabilityStatementRest.Create);
    oConf.restList[0].mode := RestfulCapabilityModeServer;
    oConf.restList[0].addExtension('http://hl7.org/fhir/StructureDefinition/capabilitystatement-websocket', request.baseUrl+'websockets');
    oConf.restList[0].interactionList.Append.code := SystemRestfulInteractionTransaction;
    oConf.restList[0].interactionList.Append.code := SystemRestfulInteractionSearchSystem;
    oConf.restList[0].interactionList.Append.code := SystemRestfulInteractionHistorySystem;
    {$IFDEF FHIR2}
    oConf.restList[0].transactionMode := TransactionModeBoth;
    {$ENDIF}
    oConf.text := TFhirNarrative.create;
    oConf.text.status := NarrativeStatusGenerated;

    {$IFDEF FHIR3}
    oConf.instantiatesList.AddItem(TFHIRUri.Create('http://hl7.org/fhir/Conformance/terminology-server'));
    {$ENDIF}
    {$IFDEF FHIR4}
    oConf.instantiatesList.AddItem(TFHIRCanonical.Create('http://hl7.org/fhir/Conformance/terminology-server'));
    {$ENDIF}
    {$IFDEF FHIR2}
    ServerContext.TerminologyServer.declareSystems(oConf);
    {$ENDIF}
    if assigned(OnPopulateConformance) and request.secure then // only add Smart App Launch things on a secure interface
      OnPopulateConformance(self, oConf);
    AddCDSHooks(oConf.restList[0]);

    html := TFslStringBuilder.Create;
    try
      html.append('<div><h2>'+ServerContext.OwnerName+' Conformance Statement</h2><p>FHIR v'+FHIR_GENERATED_VERSION+' released '+SERVER_RELEASE_DATE+'. '+
       'Server version '+SERVER_VERSION+' built '+SERVER_RELEASE_DATE+'</p><table class="grid"><tr><th>Resource Type</th><th>Profile</th><th>Read</th><th>V-Read</th><th>Search</th><th>Update</th><th>Updates</th><th>Create</th><th>Delete</th><th>History</th></tr>'+#13#10);
      for a in ServerContext.ValidatorContext.allResourceNames do
      begin
        if ServerContext.ResConfig[a].Supported and (a <> 'MessageHeader') and (a <> 'Custom') then
        begin
          if a = 'Binary' then
            html.append('<tr><td>'+a+'</td>'+
            '<td>--</td>')
          else
            html.append('<tr><td>'+a+'</td>'+
            '<td><a href="'+request.baseUrl+'StructureDefinition/'+lowercase(a)+'?format=text/html">'+lowercase(a)+'</a></td>');
          res := TFhirCapabilityStatementRestResource.create;
          try
            res.type_Element := TFhirEnum.create('http://hl7.org/fhir/resource-types', a);
            if a <> 'Binary' then
              res.profile := {$IFNDEF FHIR4}TFHIRReference.Create{$ENDIF}(request.baseUrl+'StructureDefinition/'+lowercase(a));
            if (a <> 'MessageHeader') and (a <> 'Parameters') Then
            begin
              if request.canRead(a)  then
              begin
                html.append('<td align="center"><img src="http://www.healthintersections.com.au/tick.png"/></td>');
                res.interactionList.Append.code := TypeRestfulInteractionRead;
                if ServerContext.ResConfig[a].cmdVRead then
                begin
                  html.append('<td align="center"><img src="http://www.healthintersections.com.au/tick.png"/></td>');
                  res.interactionList.Append.code := TypeRestfulInteractionVread;
                  res.readHistory := true;
                end
                else
                  html.append('<td></td>');
              end
              else
                html.append('<td align="center"></td><td align="center"></td>');
              if ServerContext.ResConfig[a].cmdSearch and request.canRead(a) then
              begin
                res.interactionList.Append.code := TypeRestfulInteractionSearchType;
                html.append('<td align="center"><img src="http://www.healthintersections.com.au/tick.png"/></td>');
              end
              else
                html.append('<td></td>');
              if ServerContext.ResConfig[a].cmdUpdate and request.canWrite(a) then
              begin
                res.interactionList.Append.code := TypeRestfulInteractionUpdate;
                html.append('<td align="center"><img src="http://www.healthintersections.com.au/tick.png"/></td>');
              end
              else
                html.append('<td></td>');
              if ServerContext.ResConfig[a].cmdHistoryType and request.canRead(a) then
              begin
                res.interactionList.Append.code := TypeRestfulInteractionHistoryType;
                html.append('<td align="center"><img src="http://www.healthintersections.com.au/tick.png"/></td>');
              end
              else
                html.append('<td></td>');
              if ServerContext.ResConfig[a].cmdCreate and request.canWrite(a) then
              begin
                res.interactionList.Append.code := TypeRestfulInteractionCreate;
                html.append('<td align="center"><img src="http://www.healthintersections.com.au/tick.png"/></td>');
              end
              else
                html.append('<td></td>');
              if ServerContext.ResConfig[a].cmdDelete and request.canWrite(a) then
              begin
                res.interactionList.Append.code := TypeRestfulInteractionDelete;
                html.append('<td align="center"><img src="http://www.healthintersections.com.au/tick.png"/></td>');
              end
              else
                html.append('<td></td>');
              if ServerContext.ResConfig[a].cmdHistoryInstance and request.canRead(a) then
              begin
                res.interactionList.Append.code := TypeRestfulInteractionHistoryInstance;
                html.append('<td align="center"><img src="http://www.healthintersections.com.au/tick.png"/></td>');
              end
              else
                html.append('<td></td>');
//                html.append('<br/>search</td><td><ul>');
              for i := 0 to ServerContext.Indexes.Indexes.count - 1 do
                if (ServerContext.Indexes.Indexes[i].ResourceType = a) then
                  if ServerContext.Indexes.Indexes[i].Name <> '_query' then
                    addParam(res.searchParamList, html, ServerContext.Indexes.Indexes[i].Name, ServerContext.Indexes.Indexes[i].uri, ServerContext.Indexes.Indexes[i].Description, MAP_TFHIRSearchParamType2[ServerContext.Indexes.Indexes[i].SearchType], ServerContext.Indexes.Indexes[i].TargetTypes);

//              addParam(res.searchParamList, html, '_id', 'http://hl7.org/fhir/search', 'Resource Logical ID', SearchParamTypeToken, []);
              addParam(res.searchParamList, html, '_text', 'http://hl7.org/fhir/search', 'General Text Search of the narrative portion', SearchParamTypeString, []);
              addParam(res.searchParamList, html, '_profile', 'http://hl7.org/fhir/search', 'Search for resources that conform to a profile', SearchParamTypeReference, []);
              addParam(res.searchParamList, html, '_security', 'http://hl7.org/fhir/search', 'Search for resources that have a particular security tag', SearchParamTypeReference, []);
              addParam(res.searchParamList, html, '_sort', 'http://hl7.org/fhir/search', 'Specify one or more other parameters to use as the sort order', SearchParamTypeToken, []);
              addParam(res.searchParamList, html, '_count', 'http://hl7.org/fhir/search', 'Number of records to return', SearchParamTypeNumber, []);
              addParam(res.searchParamList, html, '_summary', 'http://hl7.org/fhir/search', 'Return just a summary for resources that define a summary view', SearchParamTypeNumber, []);
              addParam(res.searchParamList, html, '_include', 'http://hl7.org/fhir/search', 'Additional resources to return - other resources that matching resources refer to', SearchParamTypeToken, ALL_RESOURCE_TYPE_NAMES);
              addParam(res.searchParamList, html, '_reverseInclude', 'http://hl7.org/fhir/search', 'Additional resources to return - other resources that refer to matching resources (this is trialing an extension to the specification)', SearchParamTypeToken, ALL_RESOURCE_TYPE_NAMES);
              addParam(res.searchParamList, html, '_filter', 'http://hl7.org/fhir/search', 'filter parameter as documented in the specification', SearchParamTypeToken, ALL_RESOURCE_TYPE_NAMES);

//              html.append('</ul>');                                                                                                                               }
            end;
            html.append('</tr>'#13#10);


              //<th>Search/Updates Params</th>
              // html.append('n : offset<br/>');
              // html.append('count : # resources per request<br/>');
              // html.append(m.Indexes[i]+' : ?<br/>');
            oConf.restList[0].resourceList.add(res.Link);
          finally
            res.free;
          end;
        end;
      end;
      html.append('</table>'#13#10);

      html.append('<p>Operations</p>'#13#10'<ul>'+#13#10);
      for i := 0 to FOperations.Count - 1 do
      begin
        op := oConf.restList[0].operationList.Append;
        op.name := TFhirOperation(FOperations[i]).Name;
        if TFhirOperation(FOperations[i]).formalURL <> '' then
          op.definition := {$IFNDEF FHIR4}TFHIRReference.create{$ENDIF}(TFhirOperation(FOperations[i]).formalURL)
        else
          op.definition := {$IFNDEF FHIR4}TFHIRReference.create{$ENDIF}('OperationDefinition/fso-'+op.name);
        html.append(' <li>'+op.name+': see OperationDefinition/fso-'+op.name+'</li>'#13#10);
      end;
      html.append('</ul>'#13#10);


      html.append('</div>'#13#10);
      // operations
      oConf.text.div_ := TFHIRXhtmlParser.parse(lang, xppReject, [], html.AsString);
    finally
      html.free;
    end;

    if (request.Parameters.VarExists('_graphql') and (response.Resource <> nil) and (response.Resource.ResourceType <> frtOperationOutcome)) then
      processGraphQL(request.Parameters.GetVar('_graphql'), request, response);


    AuditRest(request.session, request.internalRequestId, request.externalRequestId, request.ip, request.ResourceName, '', '', 0, request.CommandType, request.Provenance, response.httpCode, '', response.message);
  except
    on e: exception do
    begin
      AuditRest(request.session, request.internalRequestId, request.externalRequestId, request.ip, request.ResourceName, '', '', 0, request.CommandType, request.Provenance, 500, '', e.message);
      recordStack(e);
      raise;
    end;
  end;
end;

function describeResourceTypes(aTypes : TArray<String>) : String;
var
  a : String;
begin
  result := '';
  for a in aTypes do
    if result = '' then
      result := a
    else
      result := result+' / '+a;
end;

procedure TFHIROperationEngine.BuildSearchForm(request: TFHIRRequest; response : TFHIRResponse);
var
  i, j : integer;
  s, pfx, desc, rn : String;
  ix, ix2 : TFhirIndex;
  types : TArray<String>;
  m : TStringList;
  ok : boolean;
begin
  response.HTTPCode := 200;
  response.ContentType := 'text/html';
  s :=
'<?xml version="1.0" encoding="UTF-8"?>'#13#10+
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"'#13#10+
'       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'#13#10+
''#13#10+
'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'#13#10+
'<head>'#13#10+
'    <title>FHIR RESTful Server - FHIR v'+FHIR_GENERATED_VERSION+'</title>'#13#10+
TFHIRXhtmlComposer.PageLinks+
FHIR_JS+
'</head>'#13#10+
''#13#10+
'<body>'#13#10+
''#13#10+
TFHIRXhtmlComposer.Header(request.Session, request.baseUrl, request.lang, SERVER_VERSION)+
'<h2>'+GetFhirMessage('SEARCH_TITLE', lang)+'</h2>'#13#10+
'</p>'#13#10;
if Request.DefaultSearch then
s := s +
'<form action="'+request.ResourceName+'/_search" method="GET">'#13#10+
'<table class="lines">'#13#10
else
s := s +
'<form action="_search" method="GET">'#13#10+
'<table class="lines">'#13#10;

  if request.ResourceName = '' then
  begin
    s := s +'<tr><td colspan="4"><b>General search:</b></td></tr>'+#13#10+
       '<tr><td align="left">_language</td><td><input type="text" name="_language"></td><td></td><td><select title="Missing?" size="1" nam'+'e="_language:missing"><option></option><option value="1">absent</option><option name="0">present</option></select></td></tr>'+#13#10+
       '<tr><td align="left">_lastUpdated </td><td><input type="text" name="_lastUpdated"></td><td>(Date)</td><td><select title="Missing?"'+' size="1" name="_lastUpdated-missing"><option></option><option value="1">absent</option><option name="0">present</option></select></td></tr>'+#13#10+
       '<tr><td align="right"> (before)</td><td><input type="text" name="_lastUpdated:before"></td><td> (before given date)</td><td></td><'+'/tr>'+#13#10+
       '<tr><td align="right"> (after)</td><td><input type="text" name="_lastUpdated:after"></td><td> (after given date)</td><td></td></tr'+'>'+#13#10+
       '<tr><td align="left">_profile</td><td><input type="text" name="_profile"></td><td></td><td><select title="Missing?" size="1" name='+'"_profile:missing"><option></option><option value="1">absent</option><option name="0">present</option></select></td></tr>'+#13#10+
       '<tr><td align="left">_security</td><td><input type="text" name="_security"></td><td></td><td><select title="Missing?" size="1" nam'+'e="_security:missing"><option></option><option value="1">absent</option><option name="0">present</option></select></td></tr>'+#13#10+
       '<tr><td align="left">_tag</td><td><input type="text" name="_tag"></td><td></td><td><select title="Missing?" size="1" name="_tag:mi'+'ssing"><option></option><option value="1">absent</option><option name="0">present</option></select></td></tr>'+#13#10;
  end
  else
  begin
    s := s +'<tr><td colspan="4"><b>'+request.ResourceName+':</b></td></tr>'+#13#10;
    for i := 0 to TFHIRServerContext(FServerContext).Indexes.Indexes.Count - 1 Do
    begin
      ix := TFHIRServerContext(FServerContext).Indexes.Indexes[i];
      if (ix.ResourceType = request.ResourceName) and (length(ix.TargetTypes) = 0) then
      begin
        desc := FormatTextToHTML(GetFhirMessage('ndx-'+request.ResourceName+'-'+ix.name, lang, ix.Description));
        if ix.SearchType = sptDate then
        begin
          s := s + '<tr><td align="left">'+ix.Name+' </td><td><input type="text" name="'+ix.Name+'"></td><td> '+desc+' on given date (yyyy-mm-dd)</td>'+
          '<td><select title="Missing?" size="1" name="'+ix.Name+':missing"><option/><option value="1">absent</option><option name="0">present</option></select></td></tr>'#13#10;
          s := s + '<tr><td align="right"> (before)</td><td><input type="text" name="'+ix.Name+':before"></td><td> (before given date)</td><td></td></tr>'#13#10;
          s := s + '<tr><td align="right"> (after)</td><td><input type="text" name="'+ix.Name+':after"></td><td> (after given date)</td><td></td></tr>'#13#10
        end
        else
          s := s + '<tr><td align="left">'+ix.Name+'</td><td><input type="text" name="'+ix.Name+'"></td><td> '+desc+'</td>'+
          '<td><select title="Missing?" size="1" name="'+ix.Name+':missing"><option/><option value="1">absent</option><option name="0">present</option></select></td></tr>'#13#10
      end;
    end;

    for i := 0 to TFHIRServerContext(FServerContext).Indexes.Indexes.Count - 1 Do
    begin
      ix := TFHIRServerContext(FServerContext).Indexes.Indexes[i];
      if (ix.ResourceType = request.ResourceName) and (length(ix.TargetTypes) > 0) then
      begin
        pfx := ix.Name;
        types := ix.TargetTypes;
        s := s +'<tr><td colspan="4"><b>'+ix.Name+'</b> ('+describeResourceTypes(types)+')<b>:</b></td></tr>'+#13#10;
        m := TStringList.create;
        try
          for j := 0 to TFHIRServerContext(FServerContext).Indexes.Indexes.Count - 1 Do
          begin
            ix2 := TFHIRServerContext(FServerContext).Indexes.Indexes[j];
            ok := false;
            for rn in types do
              ok := ok or (ix2.ResourceType = rn);
            if (ok) and (m.IndexOf(ix2.Name) = -1) then
            begin
              desc := FormatTextToHTML(GetFhirMessage('ndx-'+request.ResourceName+'-'+ix2.name, lang, ix2.Description));
              if (ix2.searchType = sptDate) then
              begin
                s := s + '<tr>&nbsp;&nbsp;<td align="left">'+ix2.Name+' (exact)</td><td><input type="text" name="'+pfx+'.'+ix2.Name+'"></td><td> '+desc+'</td>'+
          '<td><select title="Missing?" size="1" name="'+pfx+'.'+ix2.Name+':missing"><option/><option value="1">absent</option><option name="0">present</option></select></td></tr>'#13#10;
                s := s + '<tr>&nbsp;&nbsp;<td align="right">  (before)</td><td><input type="text" name="'+pfx+'.'+ix2.Name+':before"></td><td> (before given date) </td></tr>'#13#10;
                s := s + '<tr>&nbsp;&nbsp;<td align="right">  (after)</td><td><input type="text" name="'+pfx+'.'+ix2.Name+':after"></td><td> (after given date) </td></tr>'#13#10
              end
              else
                s := s + '<tr>&nbsp;&nbsp;<td align="left">'+ix2.Name+'</td><td><input type="text" name="'+pfx+'.'+ix2.Name+'"></td><td> '+desc+'</td>'+
          '<td><select title="Missing?" size="1" name="'+pfx+'.'+ix2.Name+':missing"><option/><option value="1">absent</option><option name="0">present</option></select></td></tr>'#13#10;
              m.add(ix2.Name);
            end;
          end;
        finally
          m.Free;
        end;
      end;
    end;
  end;

  s := s +
'<tr><td colspan="2"><hr/></td></tr>'#13#10+
'<tr><td align="right">'+GetFhirMessage('SEARCH_REC_TEXT', lang)+'</td><td><input type="text" name="'+SEARCH_PARAM_NAME_TEXT+'"></td><td> '+GetFhirMessage('SEARCH_REC_TEXT_COMMENT', lang)+'</td></tr>'#13#10+
'<tr><td align="right">'+GetFhirMessage('SEARCH_REC_OFFSET', lang)+'</td><td><input type="text" name="'+SEARCH_PARAM_NAME_OFFSET+'"></td><td> '+GetFhirMessage('SEARCH_REC_OFFSET_COMMENT', lang)+'</td></tr>'#13#10+
'<tr><td align="right">'+GetFhirMessage('SEARCH_REC_COUNT', lang)+'</td><td><input type="text" name="'+SEARCH_PARAM_NAME_COUNT+'"></td><td> '+StringFormat(GetFhirMessage('SEARCH_REC_COUNT_COMMENT', lang), [SEARCH_PAGE_LIMIT])+'</td></tr>'#13#10+
'<tr><td align="right">'+GetFhirMessage('SEARCH_SORT_BY', lang)+'</td><td><select size="1" name="'+SEARCH_PARAM_NAME_SORT+'">'+#13#10;
  for i := 0 to TFHIRServerContext(FServerContext).Indexes.Indexes.Count - 1 Do
  begin
    ix := TFHIRServerContext(FServerContext).Indexes.Indexes[i];
    if (ix.ResourceType = request.ResourceName) or ((request.ResourceName = '') and (ix.Name.startsWith('_'))) then
      s := s + '<option value="'+ix.Name+'">'+ix.Name+'</option>';
  end;
  s := s + '</select></td><td></td></tr>'#13#10+
'<tr><td align="right">'+GetFhirMessage('SEARCH_SUMMARY', lang)+'</td><td><input type="checkbox" name="'+SEARCH_PARAM_NAME_SUMMARY+'" value="true"></td><td> '+GetFhirMessage('SEARCH_SUMMARY_COMMENT', lang)+'</td></tr>'#13#10+
'</table>'#13#10+
'<p><input type="submit"/></p>'#13#10+
'</form>'#13#10+
''#13#10+
'<p>'+
TFHIRXhtmlComposer.Footer(request.baseUrl, lang, request.internalRequestId);
  response.Body := s;
end;

function TFHIROperationEngine.ExecuteCreate(context: TOperationContext; request: TFHIRRequest; response: TFHIRResponse; idState: TCreateIdState; iAssignedKey: Integer): String;
begin
  raise EFHIRException.create('This server does not implement the "Create" function');
end;

procedure TFHIROperationEngine.ExecuteDelete(request: TFHIRRequest; response: TFHIRResponse);
begin
  raise EFHIRException.create('This server does not implement the "Delete" function');
end;

procedure TFHIROperationEngine.ExecuteHistory(request: TFHIRRequest; response: TFHIRResponse);
begin
  raise EFHIRException.create('This server does not implement the "History" function');
end;

procedure TFHIROperationEngine.ExecuteOperation(context: TOperationContext; request: TFHIRRequest; response: TFHIRResponse);
var
  i : integer;
  op : TFhirOperation;
begin
  for i := 0 to FOperations.count - 1 do
  begin
    op := TFhirOperation(FOperations[i]);
    if (op.HandlesRequest(request)) then
    begin
      op.Execute(context, self, request, response);
      exit;
    end;
  end;
  raise EFHIRException.create('Unsupported Operation '+request.OperationName+' on resource '+request.ResourceName);
end;

function TFHIROperationEngine.ExecutePatch(request: TFHIRRequest; response: TFHIRResponse): Boolean;
begin
  raise EFHIRException.create('This server does not implement the "Patch" function');
end;

function TFHIROperationEngine.ExecuteRead(request: TFHIRRequest; response: TFHIRResponse; ignoreHeaders : boolean) : boolean;
begin
  raise EFHIRException.create('This server does not implement the "Read" function');
end;

procedure TFHIROperationEngine.ExecuteSearch(request: TFHIRRequest; response: TFHIRResponse);
begin
  raise EFHIRException.create('This server does not implement the "Search" function');
end;

procedure TFHIROperationEngine.ExecuteTransaction(context: TOperationContext; request: TFHIRRequest; response: TFHIRResponse);
begin
  raise EFHIRException.create('This server does not implement the "Transaction" function');
end;

function TFHIROperationEngine.ExecuteUpdate(context: TOperationContext; request: TFHIRRequest; response: TFHIRResponse): Boolean;
begin
  raise EFHIRException.create('This server does not implement the "Update" function');
end;

procedure TFHIROperationEngine.ExecuteUpload(context: TOperationContext; request: TFHIRRequest; response: TFHIRResponse);
begin
  raise EFHIRException.create('This server does not implement the "Upload" function');
end;

function TFHIROperationEngine.ExecuteValidation(request: TFHIRRequest; response: TFHIRResponse; opDesc: String): boolean;
begin
  raise EFHIRException.create('This server does not implement the "Validation" function');
end;

procedure TFHIROperationEngine.ExecuteVersionRead(request: TFHIRRequest; response: TFHIRResponse);
begin
  raise EFHIRException.create('This server does not implement the "VersionRead" function');
end;

function TFHIROperationEngine.FindResource(aType, sId: String; options : TFindResourceOptions; var resourceKey, versionKey: integer; request: TFHIRRequest; response: TFHIRResponse; sessionCompartments : TFslList<TFHIRCompartmentId>): boolean;
begin
  raise EFHIRException.create('This server does not implement the "FindResource" function');
end;

function TFHIROperationEngine.GetResourceByKey(key: integer; var needSecure: boolean): TFHIRResource;
begin
  raise EFHIRException.create('This server does not implement the "GetResourceByKey" function');
end;

function TFHIROperationEngine.getResourcesByParam(aType: TFhirResourceType; name, value: string; var needSecure: boolean): TFslList<TFHIRResource>;
begin
  raise EFHIRException.create('This server does not implement the "getResourcesByParam" function');
end;

function TFHIROperationEngine.ResolveSearchId(resourceName : String; requestCompartment : TFHIRCompartmentId; sessionCompartments : TFslList<TFHIRCompartmentId>; baseURL, params : String) : TMatchingResourceList;
begin
  raise EFHIRException.create('This server does not implement the "GetResourceByKey" function');
end;

procedure TFHIROperationEngine.AddCDSHooks(conf: TFhirCapabilityStatementRest);
var
  ext : TFhirExtension;
begin
  ext := conf.addExtension('http://fhir-registry.smarthealthit.org/StructureDefinition/cds-activity');
  ext.addExtension('name', 'Fetch Patient Alerts');
  ext.addExtension('activity', TCDSHooks.patientView);
  ext.addExtension('preFetchOptional', 'Patient/{{Patient.id}}');

  ext := conf.addExtension('http://fhir-registry.smarthealthit.org/StructureDefinition/cds-activity');
  ext.addExtension('name', 'Get Terminology Information');
  ext.addExtension('activity', TCDSHooks.codeView);

  ext := conf.addExtension('http://fhir-registry.smarthealthit.org/StructureDefinition/cds-activity');
  ext.addExtension('name', 'Get identifier Information');
  ext.addExtension('activity', TCDSHooks.identifierView);
end;

procedure TFHIROperationEngine.addParam(srch : TFhirCapabilityStatementRestResourceSearchParamList; html : TFslStringBuilder; n, url, d : String; t : TFhirSearchParamTypeEnum; tgts : Array of String);
var
  param : TFhirCapabilityStatementRestResourceSearchParam;
begin
  param := TFhirCapabilityStatementRestResourceSearchParam.create;
  try
    param.name := n;
    param.definition := url;
    param.documentation := d;
    param.type_ := t;
    srch.add(param.link);
  finally
    param.free;
  end;
//  html.append('<li>'+n+' : '+FormatTextToHTML(d)+'</li>');
end;

function TFHIRStorageService.createAsyncTask(url, id: string; format : TFHIRFormat; secure : boolean): integer;
begin
  raise EFHIRException.create('Asynchronous Processing is not supported on this server');
end;

function TFHIRStorageService.createClient(lang: String; ServerContext : TFslObject; context: TFHIRWorkerContext; session: TFHIRSession): TFHIRClient;
var
  int : TFHIRInternalCommunicator;
begin
  int := TFHIRInternalCommunicator.Create;
  try
    int.FServerContext := ServerContext.Link;
    int.FEngine := createOperationContext(lang).link as TFHIROperationEngine;
    int.Context := context.link;
    int.session := session.link;
    result := TFHIRClient.Create((ServerContext as TFHIRServerContext).ValidatorContext.Link, lang, int.Link);
  finally
    int.Free;
  end;
end;

procedure TFHIRStorageService.Yield(client: TFHIRClient; exception: Exception);
begin
  yield(TFHIRInternalCommunicator(client.Communicator).FEngine, exception);
  client.Free;
end;

{ TMatchingResourceList }

function TMatchingResourceList.GetEntry(iIndex: Integer): TMatchingResource;
begin
  result := TMatchingResource(ObjectByIndex[iIndex]);
end;


{ TFHIRInternalCommunicator }

function TFHIRInternalCommunicator.address: String;
begin
  result := '(internal)';
end;

function TFHIRInternalCommunicator.conformanceV(summary: boolean): TFHIRResourceV;
var
  req : TFHIRRequest;
  resp : TFHIRResponse;
begin
  req := TFHIRRequest.Create(context, roOperation, nil);
  try
    req.CommandType := fcmdConformanceStmt;
    resp := TFHIRResponse.Create;
    try
      FEngine.ExecuteConformanceStmt(req, resp);
      if resp.HTTPCode >= 300 then
        if (resp.Resource <> nil) and (resp.Resource is TFhirOperationOutcome) then
          raise EFHIRClientException.Create((resp.Resource as TFhirOperationOutcome).asExceptionMessage, opWrapper.Create(resp.Resource))
        else
          raise EFHIRClientException.Create(resp.Body, opWrapper.Create(BuildOperationOutcome('en', resp.Body)));
      result := resp.Resource.Link as TFhirCapabilityStatement;
    finally
      resp.Free;
    end;
  finally
    req.Free;
  end;
end;

function TFHIRInternalCommunicator.createResourceV(resource: TFhirResourceV; var id: String): TFHIRResourceV;
var
  req : TFHIRRequest;
  resp : TFHIRResponse;
  ctxt : TOperationContext;
begin
  ctxt := TOperationContext.Create(false, nil, 'internal');
  try
    req := TFHIRRequest.Create(context, roOperation, nil);
    try
      req.CommandType := fcmdCreate;
      req.resource := resource.link as TFHIRResource;
      req.ResourceName := resource.fhirType;
      req.Provenance := FClient.provenance.Link as TFhirProvenance;

      resp := TFHIRResponse.Create;
      try
        FEngine.ExecuteCreate(ctxt, req, resp, idNoNew, 0);
        if resp.HTTPCode >= 300 then
          if (resp.Resource <> nil) and (resp.Resource is TFhirOperationOutcome) then
            raise EFHIRClientException.Create((resp.Resource as TFhirOperationOutcome).asExceptionMessage, opWrapper.Create(resp.Resource))
          else
            raise EFHIRClientException.Create(resp.Body, opWrapper.Create(BuildOperationOutcome('en', resp.Body)));
        id := resp.Id;
        result := resp.Resource.Link;
      finally
        resp.Free;
      end;
    finally
      req.Free;
    end;
  finally
    ctxt.free;
  end;
end;

function TFHIRInternalCommunicator.customGet(path: String; headers: THTTPHeaders): TFslBuffer;
begin
  raise EFHIRException.create('Not done yet');
end;

function TFHIRInternalCommunicator.customPost(path: String; headers: THTTPHeaders; body: TFslBuffer): TFslBuffer;
begin
  raise EFHIRException.create('Not done yet');
end;

procedure TFHIRInternalCommunicator.deleteResourceV(atype: TFhirResourceTypeV; id: String);
begin
  raise EFHIRException.create('Not done yet');
end;

destructor TFHIRInternalCommunicator.Destroy;
begin
  FEngine.Free;
  FContext.Free;
  FSession.Free;
  FServerContext.Free;
  inherited;
end;

function TFHIRInternalCommunicator.historyTypeV(atype: TFhirResourceTypeV; allRecords: boolean; params : string): TFHIRResourceV;
begin
  raise EFHIRException.create('Not done yet');
end;

function TFHIRInternalCommunicator.link: TFHIRInternalCommunicator;
begin
  result := TFHIRInternalCommunicator(inherited link);
end;

function TFHIRInternalCommunicator.operationV(atype: TFHIRResourceTypeV; id, opName: String; params: TFHIRResourceV): TFHIRResourceV;
begin
  raise EFHIRException.create('Not done yet');
end;

function TFHIRInternalCommunicator.operationV(atype: TFhirResourceTypeV; opName: String; params: TFHIRResourceV): TFHIRResourceV;
begin
  raise EFHIRException.create('Not done yet');
end;

function TFHIRInternalCommunicator.readResourceV(atype: TFhirResourceTypeV; id: String): TFHIRResourceV;
var
  req : TFHIRRequest;
  resp : TFHIRResponse;
  ctxt : TOperationContext;
begin
  ctxt := TOperationContext.Create(false, nil, 'internal');
  try
    req := TFHIRRequest.Create(context, roOperation, nil);
    try
      req.CommandType := fcmdRead;
      req.ResourceName := aType;
      req.id := id;

      resp := TFHIRResponse.Create;
      try
        FEngine.ExecuteRead(req, resp, true);
        if resp.HTTPCode >= 300 then
          if (resp.Resource <> nil) and (resp.Resource is TFhirOperationOutcome) then
            raise EFHIRClientException.Create((resp.Resource as TFhirOperationOutcome).asExceptionMessage, opWrapper.Create(resp.Resource))
          else
            raise EFHIRClientException.Create(resp.Body, opWrapper.Create(BuildOperationOutcome('en', resp.Body)));
        id := resp.Id;
        result := resp.Resource.Link;
      finally
        resp.Free;
      end;
    finally
      req.Free;
    end;
  finally
    ctxt.free;
  end;
end;


procedure TFHIRInternalCommunicator.doGetBundleBuilder(request : TFHIRRequest; context: TFHIRResponse; aType: TFhirBundleTypeEnum; out builder: TFhirBundleBuilder);
begin
  if context.Format = ffNDJson then
    raise EFHIRException.CreateLang('NDJSON-ASYNC', request.Lang);
  builder := TFHIRBundleBuilderSimple.Create(TFHIRBundle.create(aType));
end;


function TFHIRInternalCommunicator.searchV(atype: TFhirResourceTypeV; allRecords: boolean; params: string): TFhirResourceV;
var
  req : TFHIRRequest;
  resp : TFHIRResponse;
  ctxt : TOperationContext;
begin
  ctxt := TOperationContext.Create(false, nil, 'internal');
  try
    req := TFHIRRequest.Create(context, roOperation, nil);
    try
      req.CommandType := fcmdSearch;
      req.ResourceName := aType;
      req.Parameters := TParseMap.create(params+'&__wantObject=true');
      req.internalRequestId := TFHIRServerContext(FServerContext).nextRequestId;

      resp := TFHIRResponse.Create;
      try
        resp.OnCreateBuilder := doGetBundleBuilder;
        FEngine.ExecuteSearch(req, resp);
        if resp.HTTPCode >= 300 then
          if (resp.Resource <> nil) and (resp.Resource is TFhirOperationOutcome) then
            raise EFHIRClientException.Create((resp.Resource as TFhirOperationOutcome).asExceptionMessage, opWrapper.Create(resp.Resource))
          else
            raise EFHIRClientException.Create(resp.Body, opWrapper.Create(BuildOperationOutcome('en', resp.Body)));
        result := resp.Resource.Link as TFHIRBundle;
      finally
        resp.Free;
      end;
    finally
      req.Free;
    end;
  finally
    ctxt.free;
  end;
end;

function TFHIRInternalCommunicator.searchAgainV(link: String): TFHIRResourceV;
begin
  raise EFHIRException.create('Not done yet');
end;

function TFHIRInternalCommunicator.searchPostV(atype: TFhirResourceTypeV; allRecords: boolean; params : TStringList; resource: TFhirResourceV): TFhirResourceV;
begin
  raise EFHIRException.create('Not done yet');
end;

procedure TFHIRInternalCommunicator.SetContext(const Value: TFHIRWorkerContext);
begin
  FContext.Free;
  FContext := Value;
end;

procedure TFHIRInternalCommunicator.SetSession(const Value: TFHIRSession);
begin
  FSession.Free;
  FSession := Value;
end;

procedure TFHIRInternalCommunicator.terminate;
begin
  inherited;

end;

function TFHIRInternalCommunicator.transactionV(bundle: TFhirResourceV): TFhirResourceV;
begin
  raise EFHIRException.create('Not done yet');
end;

function TFHIRInternalCommunicator.updateResourceV(resource: TFhirResourceV): TFhirResourceV;
begin
  raise EFHIRException.create('Not done yet');
end;

{ TFhirOperation }

function TFhirOperation.Name: String;
begin
  result := '';
end;

function TFhirOperation.owningResource: TFhirResourceType;
var
  t : TFhirResourceType;
  b : boolean;
begin
  result := frtNull;
  b := false;
  for t in Types do
    if b then
      raise EFHIRException.create('Multiple types for operation')
    else
    begin
      result := t;
      b := true;
    end;
  if (not b) then
    raise EFHIRException.create('No types for operation');
end;

function TFhirOperation.resolvePatient(manager: TFHIROperationEngine; request: TFHIRRequest; ref: String): integer;
var
  parts : TArray<String>;
  versionKey : integer;
begin
  parts := ref.Split(['/']);
  if length(parts) <> 2 then
    raise EFHIRException.create('Unable to understand the subject reference "'+ref+'"');
  if NOT manager.FindResource(parts[0], parts[1], [], result, versionKey, request, nil, nil) then
    result := 0;
end;

function TFhirOperation.Types: TFhirResourceTypeSet;
begin
  result := [];
end;

function TFhirOperation.CreateBaseDefinition(base : String): TFHIROperationDefinition;
begin
  result := TFhirOperationDefinition.Create;
  try
    result.id := 'fso-'+name;
    result.meta := TFhirMeta.Create;
    result.meta.lastUpdated := TDateTimeEx.fromXml(FHIR_GENERATED_DATE);
    result.meta.versionId := SERVER_VERSION;
    result.url := AppendForwardSlash(base)+'OperationDefinition/fso-'+name;
    result.version := FHIR_GENERATED_VERSION;
    result.name := 'Operation Definition for "'+name+'"';
    result.publisher := 'Grahame Grieve';
    with result.contactList.Append do
      with telecomList.Append do
      begin
        system := ContactPointSystemEmail;
        value := 'grahame@fhir.org';
      end;
    result.description := 'Reference FHIR Server Operation Definition for "'+name+'"';
    result.status := PublicationStatusDraft;
    result.experimental := false;
    result.date := TDateTimeEx.fromXml(FHIR_GENERATED_DATE);
    result.kind := OperationKindOperation;
    result.code := name;
    result.base := {$IFNDEF FHIR4}TFhirReference.Create{$ENDIF}('http://hl7.org/fhir/OperationDefinition/'+name);
    result.Link;
  finally
    result.Free;
  end;
end;

function TFhirOperation.CreateDefinition(base : String): TFHIROperationDefinition;
begin
  result := nil;
end;

procedure TFhirOperation.Execute(context : TOperationContext; manager: TFHIROperationEngine; request: TFHIRRequest; response: TFHIRResponse);
begin
  // nothing
end;

function TFhirOperation.formalURL: String;
begin
  result := '';
end;

function TFhirOperation.HandlesRequest(request: TFHIRRequest): boolean;
var
  t : TFhirResourceType;
begin
  result := (request.OperationName = Name) and (request.ResourceEnum in Types);
  if result then
  begin
    t := owningResource;
    if t = frtNull then
      t := request.ResourceEnum;
    if t = frtNull then
      result := ((isWrite and request.canWrite('') or (not isWrite and request.canRead('')))) // todo: what should it be?
    else
      result := ((isWrite and request.canWrite(CODES_TFHIRresourceType[t])) or (not isWrite and request.canRead(CODES_TFHIRresourceType[t])));
  end;
end;

function TFhirOperation.isWrite: boolean;
begin
  result := false;
end;

function TFhirOperation.makeParams(request: TFHIRRequest): TFhirParameters;
var
  i : integer;
begin
  if (request.Resource <> nil) and (request.Resource is TFHIRParameters) then
    result := request.Resource.Link as TFHIRParameters
  else
    result := TFhirParameters.Create;
  try
    for i := 0 to request.Parameters.getItemCount - 1 do
      result.AddParameter(request.Parameters.VarName(i), request.Parameters.getVar(request.Parameters.VarName(i)));
    result.link;
  finally
    result.Free;
  end;
end;


{ TAsyncTaskInformation }

function TAsyncTaskInformation.link: TAsyncTaskInformation;
begin
  result := TAsyncTaskInformation(inherited link);
end;

{ TRegisteredClientInformation }

constructor TRegisteredClientInformation.Create;
begin
  inherited;
  FRedirects := TStringList.Create;
end;

destructor TRegisteredClientInformation.Destroy;
begin
  FRedirects.Free;
  inherited;
end;

function TRegisteredClientInformation.link: TRegisteredClientInformation;
begin
  result := TRegisteredClientInformation(inherited Link);
end;

end.


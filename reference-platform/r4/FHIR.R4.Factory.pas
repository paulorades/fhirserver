﻿unit FHIR.R4.Factory;

{$I fhir.inc}

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

// FHIR v3.4.0 generated 2018-05-15T06:48:00+10:00

uses
  FHIR.Ucum.IFace,
  FHIR.Base.Objects, FHIR.Base.Parser, FHIR.Base.Validator, FHIR.Base.Narrative, FHIR.Base.Factory, FHIR.Base.PathEngine, FHIR.Base.Xhtml, FHIR.Base.Common,
  FHIR.Client.Base, FHIR.Client.Threaded;

type
  TFHIRFactoryR4 = class (TFHIRFactory)
  public
    function version : TFHIRVersion; override;
    function versionString : String; override;
    function description : String; override;
    function resourceNames : TArray<String>; override;
    function makeParser(worker : TFHIRWorkerContextV; format : TFHIRFormat; lang : String) : TFHIRParser; override;
    function makeComposer(worker : TFHIRWorkerContextV; format : TFHIRFormat; lang : String; style: TFHIROutputStyle) : TFHIRComposer; override;
    function makeValidator(worker : TFHIRWorkerContextV) : TFHIRValidatorV; override;
    function makeGenerator(worker : TFHIRWorkerContextV) : TFHIRNarrativeGeneratorBase; override;
    function makePathEngine(worker : TFHIRWorkerContextV; ucum : TUcumServiceInterface) : TFHIRPathEngineV; override;
    function createFromProfile(worker : TFHIRWorkerContextV; profile : TFhirStructureDefinitionW) : TFHIRResourceV; override;
    function makeClient(worker : TFHIRWorkerContextV; url : String; kind : TFHIRClientType; fmt : TFHIRFormat; timeout : cardinal; proxy : String) : TFhirClientV; overload; override;
    function makeClientThreaded(worker : TFHIRWorkerContextV; internal : TFhirClientV; event : TThreadManagementEvent) : TFhirClientV; overload; override;

    function getXhtml(res : TFHIRResourceV) : TFHIRXhtmlNode; override;
    function resetXhtml(res : TFHIRResourceV) : TFHIRXhtmlNode; override;

    procedure checkNoImplicitRules(res : TFHIRObject; method, param : string); override;
    procedure checkNoModifiers(res : TFHIRObject; method, param : string; allowed : TArray<String> = []); override;

    function makeByName(const name : String) : TFHIRObject; override;
    function makeBoolean(b : boolean): TFHIRObject; override;
    function makeCode(s : string) : TFHIRObject; override;
    function makeString(s : string) : TFHIRObject; override;
    function makeInteger(s : string) : TFHIRObject; override;
    function makeDecimal(s : string) : TFHIRObject; override;
    function makeBase64Binary(s : string) : TFHIRObject; override;
    function makeParameters : TFHIRParametersW; override;
    function wrapCapabilityStatement(r : TFHIRResourceV) : TFHIRCapabilityStatementW; override;
    function wrapStructureDefinition(r : TFHIRResourceV) : TFhirStructureDefinitionW; override;
    function wrapValueSet(r : TFHIRResourceV) : TFhirValueSetW; override;
    function wrapCodeSystem(r : TFHIRResourceV) : TFhirCodeSystemW; override;
    function wrapExtension(o : TFHIRObject) : TFhirExtensionW; override;
    function wrapCoding(o : TFHIRObject) : TFhirCodingW; override;
    function wrapOperationOutcome(r : TFHIRResourceV) : TFhirOperationOutcomeW; override;
    function wrapBundle(r : TFHIRResourceV) : TFhirBundleW; override;
  end;
  TFHIRFactoryX = TFHIRFactoryR4;

implementation

uses
  Soap.EncdDecd,
  FHIR.Client.HTTP,
  FHIR.R4.Types, FHIR.R4.Resources, FHIR.R4.Parser, FHIR.R4.Context, FHIR.R4.Validator, FHIR.R4.Profiles,
  FHIR.R4.Narrative, FHIR.R4.PathEngine, FHIR.R4.Constants, FHIR.R4.Client, FHIR.R4.Common, FHIR.R4.Utilities;

{ TFHIRFactoryR4 }

procedure TFHIRFactoryR4.checkNoImplicitRules(res: TFHIRObject; method, param: string);
begin
  if res is TFHIRResource then
    (res as TFHIRResource).checkNoImplicitRules(method, param);
end;

procedure TFHIRFactoryR4.checkNoModifiers(res: TFHIRObject; method, param: string; allowed : TArray<String> = []);
begin
  if res is TFHIRDomainResource then
    TFHIRDomainResource(res).checkNoModifiers(method, param)
  else if res is TFHIRBackboneElement then
    TFHIRBackboneElement(res).checkNoModifiers(method, param)
end;

function TFHIRFactoryR4.createFromProfile(worker: TFHIRWorkerContextV; profile: TFhirStructureDefinitionW): TFHIRResourceV;
var
  pu : TProfileUtilities;
begin
  pu := TProfileUtilities.create(worker.Link as TFHIRWorkerContext, nil);
  try
    result := pu.populateByProfile(profile.Resource as TFhirStructureDefinition);
  finally
    pu.Free;
  end;
end;

function TFHIRFactoryR4.description: String;
begin
  result := 'R4 ('+FHIR_GENERATED_VERSION+')';
end;

function TFHIRFactoryR4.getXhtml(res: TFHIRResourceV): TFHIRXhtmlNode;
var
  r : TFHIRDomainResource;
begin
  if res = nil then
    exit(nil);
  if not (res is TFHIRDomainResource) then
    exit(nil);
  r := res as TFHIRDomainResource;
  if (r.text = nil) then
    result := nil
  else
    result := r.text.div_;
end;

function TFHIRFactoryR4.makeClient(worker: TFHIRWorkerContextV; url: String; kind : TFHIRClientType; fmt : TFHIRFormat; timeout: cardinal; proxy: String): TFhirClientV;
var
  http : TFHIRHTTPCommunicator;
begin
  http := TFHIRHTTPCommunicator.Create(url);
  try
    if kind = fctCrossPlatform then
      http.UseIndy := true;
    http.timeout := timeout;
    http.proxy := proxy;
    result := TFhirClient4.create(worker, 'en', http.link);
    try
      result.format := fmt;
      result.link;
    finally
      result.Free;
    end;
  finally
    http.free;
  end;
end;

function TFHIRFactoryR4.makeClientThreaded(worker: TFHIRWorkerContextV; internal: TFhirClientV; event: TThreadManagementEvent): TFhirClientV;
var
  c : TFhirThreadedCommunicator;
begin
  c := TFhirThreadedCommunicator.Create(internal, event);
  try
    result := TFhirClient4.create(worker, 'en', c.link);
    try
      result.format := internal.format;
      result.link;
    finally
      result.Free;
    end;
  finally
    c.free;
  end;
end;

function TFHIRFactoryR4.makeCode(s: string): TFHIRObject;
begin
  result := TFhirCode.Create(s);
end;

function TFHIRFactoryR4.makeComposer(worker: TFHIRWorkerContextV; format: TFHIRFormat; lang: String; style: TFHIROutputStyle): TFHIRComposer;
begin
  result := TFHIRParsers4.composer(worker as TFHIRWorkerContext, format, lang, style);
end;

function TFHIRFactoryR4.makeDecimal(s: string): TFHIRObject;
begin
  result := TFhirDecimal.Create(s);
end;

function TFHIRFactoryR4.makeGenerator(worker: TFHIRWorkerContextV): TFHIRNarrativeGeneratorBase;
begin
  result := TFHIRNarrativeGenerator.create(worker);
end;

function TFHIRFactoryR4.makeInteger(s: string): TFHIRObject;
begin
  result := TFhirInteger.Create(s);
end;

function TFHIRFactoryR4.makeParameters: TFHIRParametersW;
begin
  result := TFHIRParameters4.Create(TFHIRParameters.Create);
end;

function TFHIRFactoryR4.makeParser(worker: TFHIRWorkerContextV; format: TFHIRFormat; lang: String): TFHIRParser;
begin
  result := TFHIRParsers4.parser(worker as TFHIRWorkerContext, format, lang);
end;

function TFHIRFactoryR4.makePathEngine(worker: TFHIRWorkerContextV; ucum : TUcumServiceInterface): TFHIRPathEngineV;
begin
  result := TFHIRPathEngine.Create(worker as TFHIRWorkerContext, ucum);
end;

function TFHIRFactoryR4.makeString(s: string): TFHIRObject;
begin
  result := TFhirString.Create(s);
end;

function TFHIRFactoryR4.makeValidator(worker: TFHIRWorkerContextV): TFHIRValidatorV;
begin
  result := TFHIRValidator4.Create(worker as TFHIRWorkerContext);
end;

function TFHIRFactoryR4.resetXhtml(res: TFHIRResourceV): TFHIRXhtmlNode;
var
  r : TFHIRDomainResource;
begin
  if res = nil then
    exit(nil);
  if not (res is TFHIRDomainResource) then
    exit(nil);
  r := res as TFHIRDomainResource;
  r.text := TFHIRNarrative.Create;
  r.text.status := NarrativeStatusGenerated;
  r.text.div_ := TFhirXHtmlNode.Create('div');
  result := r.text.div_;
end;

function TFHIRFactoryR4.resourceNames: TArray<String>;
var
  a : TFhirResourceType;
begin
  SetLength(result, length(CODES_TFhirResourceType)-2);
  for a in ALL_RESOURCE_TYPES do
    if not (a in [frtNull, frtCustom]) then
      result[ord(a)-1] := CODES_TFhirResourceType[a];
end;

function TFHIRFactoryR4.version: TFHIRVersion;
begin
  result := fhirVersionRelease4;
end;

function TFHIRFactoryR4.versionString: String;
begin
  result := FHIR_GENERATED_VERSION;
end;

function TFHIRFactoryR4.wrapBundle(r: TFHIRResourceV): TFhirBundleW;
begin
  if r = nil then
    result := nil
  else
    result := TFhirBundle4.Create(r);
end;

function TFHIRFactoryR4.wrapCapabilityStatement(r: TFHIRResourceV): TFHIRCapabilityStatementW;
begin
  if r = nil then
    result := nil
  else
    result := TFHIRCapabilityStatement4.create(r);
end;

function TFHIRFactoryR4.wrapCodeSystem(r: TFHIRResourceV): TFhirCodeSystemW;
begin
  if r = nil then
    result := nil
  else
    result := TFHIRCodeSystem4.create(r);
end;

function TFHIRFactoryR4.wrapCoding(o: TFHIRObject): TFhirCodingW;
begin
  result := TFhirCoding4.create(o);
end;

function TFHIRFactoryR4.wrapExtension(o: TFHIRObject): TFhirExtensionW;
begin
  result := TFhirExtension4.create(o);
end;

function TFHIRFactoryR4.wrapOperationOutcome(r: TFHIRResourceV): TFhirOperationOutcomeW;
begin
  if r = nil then
    result := nil
  else
    result := TFhirOperationOutcome4.Create(r);
end;

function TFHIRFactoryR4.wrapStructureDefinition(r: TFHIRResourceV): TFhirStructureDefinitionW;
begin
  if r = nil then
    result := nil
  else
    result := TFHIRStructureDefinition4.create(r);
end;

function TFHIRFactoryR4.wrapValueSet(r: TFHIRResourceV): TFhirValueSetW;
begin
  if r = nil then
    result := nil
  else
    result := TFHIRValueSet4.create(r);
end;

function TFHIRFactoryR4.makeBase64Binary(s: string): TFHIRObject;
begin
  result := TFhirBase64Binary.Create(decodeBase64(s));
end;

function TFHIRFactoryR4.makeBoolean(b: boolean): TFHIRObject;
begin
  result := TFhirBoolean.Create(b);
end;

function TFHIRFactoryR4.makeByName(const name : String) : TFHIRObject;
begin
  if name = 'enum' then
    result := TFhirEnum.create()
  else if name = 'date' then
    result := TFhirDate.create()
  else if name = 'dateTime' then
    result := TFhirDateTime.create()
  else if name = 'string' then
    result := TFhirString.create()
  else if name = 'integer' then
    result := TFhirInteger.create()
  else if name = 'uri' then
    result := TFhirUri.create()
  else if name = 'instant' then
    result := TFhirInstant.create()
  else if name = 'xhtml' then
    result := TFhirXhtml.create()
  else if name = 'boolean' then
    result := TFhirBoolean.create()
  else if name = 'base64Binary' then
    result := TFhirBase64Binary.create()
  else if name = 'time' then
    result := TFhirTime.create()
  else if name = 'decimal' then
    result := TFhirDecimal.create()
  else if name = 'code' then
    result := TFhirCode.create()
  else if name = 'canonical' then
    result := TFhirCanonical.create()
  else if name = 'oid' then
    result := TFhirOid.create()
  else if name = 'uuid' then
    result := TFhirUuid.create()
  else if name = 'url' then
    result := TFhirUrl.create()
  else if name = 'markdown' then
    result := TFhirMarkdown.create()
  else if name = 'unsignedInt' then
    result := TFhirUnsignedInt.create()
  else if name = 'id' then
    result := TFhirId.create()
  else if name = 'positiveInt' then
    result := TFhirPositiveInt.create()
{$IFDEF FHIR_PARAMETERS}
  else if name = 'Parameters.parameter' then
    result := TFhirParametersParameter.create()
  else if name = 'Parameters' then
    result := TFhirParameters.create()
{$ENDIF FHIR_PARAMETERS}
  else if name = 'Extension' then
    result := TFhirExtension.create()
  else if name = 'Narrative' then
    result := TFhirNarrative.create()
  else if name = 'Contributor' then
    result := TFhirContributor.create()
  else if name = 'Attachment' then
    result := TFhirAttachment.create()
  else if name = 'DataRequirement.codeFilter' then
    result := TFhirDataRequirementCodeFilter.create()
  else if name = 'DataRequirement.dateFilter' then
    result := TFhirDataRequirementDateFilter.create()
  else if name = 'DataRequirement.sort' then
    result := TFhirDataRequirementSort.create()
  else if name = 'DataRequirement' then
    result := TFhirDataRequirement.create()
  else if name = 'Dosage.doseAndRate' then
    result := TFhirDosageDoseAndRate.create()
  else if name = 'Dosage' then
    result := TFhirDosage.create()
  else if name = 'MarketingStatus' then
    result := TFhirMarketingStatus.create()
  else if name = 'Identifier' then
    result := TFhirIdentifier.create()
  else if name = 'SubstanceAmount.referenceRange' then
    result := TFhirSubstanceAmountReferenceRange.create()
  else if name = 'SubstanceAmount' then
    result := TFhirSubstanceAmount.create()
  else if name = 'Coding' then
    result := TFhirCoding.create()
  else if name = 'SampledData' then
    result := TFhirSampledData.create()
  else if name = 'Ratio' then
    result := TFhirRatio.create()
  else if name = 'SubstanceMoiety' then
    result := TFhirSubstanceMoiety.create()
  else if name = 'Reference' then
    result := TFhirReference.create()
  else if name = 'TriggerDefinition.condition' then
    result := TFhirTriggerDefinitionCondition.create()
  else if name = 'TriggerDefinition' then
    result := TFhirTriggerDefinition.create()
  else if name = 'Period' then
    result := TFhirPeriod.create()
  else if name = 'Quantity' then
    result := TFhirQuantity.create()
  else if name = 'Range' then
    result := TFhirRange.create()
  else if name = 'RelatedArtifact' then
    result := TFhirRelatedArtifact.create()
  else if name = 'Annotation' then
    result := TFhirAnnotation.create()
  else if name = 'ProductShelfLife' then
    result := TFhirProductShelfLife.create()
  else if name = 'ContactDetail' then
    result := TFhirContactDetail.create()
  else if name = 'UsageContext' then
    result := TFhirUsageContext.create()
  else if name = 'Signature' then
    result := TFhirSignature.create()
  else if name = 'ProdCharacteristic' then
    result := TFhirProdCharacteristic.create()
  else if name = 'CodeableConcept' then
    result := TFhirCodeableConcept.create()
  else if name = 'ParameterDefinition' then
    result := TFhirParameterDefinition.create()
  else if name = 'ContactPoint' then
    result := TFhirContactPoint.create()
  else if name = 'HumanName' then
    result := TFhirHumanName.create()
  else if name = 'Meta' then
    result := TFhirMeta.create()
  else if name = 'Address' then
    result := TFhirAddress.create()
  else if name = 'ElementDefinition.slicing' then
    result := TFhirElementDefinitionSlicing.create()
  else if name = 'ElementDefinition.slicing.discriminator' then
    result := TFhirElementDefinitionSlicingDiscriminator.create()
  else if name = 'ElementDefinition.base' then
    result := TFhirElementDefinitionBase.create()
  else if name = 'ElementDefinition.type' then
    result := TFhirElementDefinitionType.create()
  else if name = 'ElementDefinition.example' then
    result := TFhirElementDefinitionExample.create()
  else if name = 'ElementDefinition.constraint' then
    result := TFhirElementDefinitionConstraint.create()
  else if name = 'ElementDefinition.binding' then
    result := TFhirElementDefinitionBinding.create()
  else if name = 'ElementDefinition.mapping' then
    result := TFhirElementDefinitionMapping.create()
  else if name = 'ElementDefinition' then
    result := TFhirElementDefinition.create()
  else if name = 'Timing.repeat' then
    result := TFhirTimingRepeat.create()
  else if name = 'Timing' then
    result := TFhirTiming.create()
  else if name = 'Count' then
    result := TFhirCount.create()
  else if name = 'Money' then
    result := TFhirMoney.create()
  else if name = 'Age' then
    result := TFhirAge.create()
  else if name = 'Distance' then
    result := TFhirDistance.create()
  else if name = 'Duration' then
    result := TFhirDuration.create()
{$IFDEF FHIR_ACCOUNT}
  else if name = 'Account.coverage' then
    result := TFhirAccountCoverage.create()
  else if name = 'Account.guarantor' then
    result := TFhirAccountGuarantor.create()
  else if name = 'Account' then
    result := TFhirAccount.create()
{$ENDIF FHIR_ACCOUNT}
{$IFDEF FHIR_ACTIVITYDEFINITION}
  else if name = 'ActivityDefinition.participant' then
    result := TFhirActivityDefinitionParticipant.create()
  else if name = 'ActivityDefinition.dynamicValue' then
    result := TFhirActivityDefinitionDynamicValue.create()
  else if name = 'ActivityDefinition' then
    result := TFhirActivityDefinition.create()
{$ENDIF FHIR_ACTIVITYDEFINITION}
{$IFDEF FHIR_ADVERSEEVENT}
  else if name = 'AdverseEvent.suspectEntity' then
    result := TFhirAdverseEventSuspectEntity.create()
  else if name = 'AdverseEvent.suspectEntity.causality' then
    result := TFhirAdverseEventSuspectEntityCausality.create()
  else if name = 'AdverseEvent' then
    result := TFhirAdverseEvent.create()
{$ENDIF FHIR_ADVERSEEVENT}
{$IFDEF FHIR_ALLERGYINTOLERANCE}
  else if name = 'AllergyIntolerance.reaction' then
    result := TFhirAllergyIntoleranceReaction.create()
  else if name = 'AllergyIntolerance' then
    result := TFhirAllergyIntolerance.create()
{$ENDIF FHIR_ALLERGYINTOLERANCE}
{$IFDEF FHIR_APPOINTMENT}
  else if name = 'Appointment.participant' then
    result := TFhirAppointmentParticipant.create()
  else if name = 'Appointment' then
    result := TFhirAppointment.create()
{$ENDIF FHIR_APPOINTMENT}
{$IFDEF FHIR_APPOINTMENTRESPONSE}
  else if name = 'AppointmentResponse' then
    result := TFhirAppointmentResponse.create()
{$ENDIF FHIR_APPOINTMENTRESPONSE}
{$IFDEF FHIR_AUDITEVENT}
  else if name = 'AuditEvent.agent' then
    result := TFhirAuditEventAgent.create()
  else if name = 'AuditEvent.agent.network' then
    result := TFhirAuditEventAgentNetwork.create()
  else if name = 'AuditEvent.source' then
    result := TFhirAuditEventSource.create()
  else if name = 'AuditEvent.entity' then
    result := TFhirAuditEventEntity.create()
  else if name = 'AuditEvent.entity.detail' then
    result := TFhirAuditEventEntityDetail.create()
  else if name = 'AuditEvent' then
    result := TFhirAuditEvent.create()
{$ENDIF FHIR_AUDITEVENT}
{$IFDEF FHIR_BASIC}
  else if name = 'Basic' then
    result := TFhirBasic.create()
{$ENDIF FHIR_BASIC}
{$IFDEF FHIR_BINARY}
  else if name = 'Binary' then
    result := TFhirBinary.create()
{$ENDIF FHIR_BINARY}
{$IFDEF FHIR_BIOLOGICALLYDERIVEDPRODUCT}
  else if name = 'BiologicallyDerivedProduct.collection' then
    result := TFhirBiologicallyDerivedProductCollection.create()
  else if name = 'BiologicallyDerivedProduct.processing' then
    result := TFhirBiologicallyDerivedProductProcessing.create()
  else if name = 'BiologicallyDerivedProduct.manipulation' then
    result := TFhirBiologicallyDerivedProductManipulation.create()
  else if name = 'BiologicallyDerivedProduct.storage' then
    result := TFhirBiologicallyDerivedProductStorage.create()
  else if name = 'BiologicallyDerivedProduct' then
    result := TFhirBiologicallyDerivedProduct.create()
{$ENDIF FHIR_BIOLOGICALLYDERIVEDPRODUCT}
{$IFDEF FHIR_BODYSTRUCTURE}
  else if name = 'BodyStructure' then
    result := TFhirBodyStructure.create()
{$ENDIF FHIR_BODYSTRUCTURE}
{$IFDEF FHIR_BUNDLE}
  else if name = 'Bundle.link' then
    result := TFhirBundleLink.create()
  else if name = 'Bundle.entry' then
    result := TFhirBundleEntry.create()
  else if name = 'Bundle.entry.search' then
    result := TFhirBundleEntrySearch.create()
  else if name = 'Bundle.entry.request' then
    result := TFhirBundleEntryRequest.create()
  else if name = 'Bundle.entry.response' then
    result := TFhirBundleEntryResponse.create()
  else if name = 'Bundle' then
    result := TFhirBundle.create()
{$ENDIF FHIR_BUNDLE}
{$IFDEF FHIR_CAPABILITYSTATEMENT}
  else if name = 'CapabilityStatement.software' then
    result := TFhirCapabilityStatementSoftware.create()
  else if name = 'CapabilityStatement.implementation' then
    result := TFhirCapabilityStatementImplementation.create()
  else if name = 'CapabilityStatement.rest' then
    result := TFhirCapabilityStatementRest.create()
  else if name = 'CapabilityStatement.rest.security' then
    result := TFhirCapabilityStatementRestSecurity.create()
  else if name = 'CapabilityStatement.rest.resource' then
    result := TFhirCapabilityStatementRestResource.create()
  else if name = 'CapabilityStatement.rest.resource.interaction' then
    result := TFhirCapabilityStatementRestResourceInteraction.create()
  else if name = 'CapabilityStatement.rest.resource.searchParam' then
    result := TFhirCapabilityStatementRestResourceSearchParam.create()
  else if name = 'CapabilityStatement.rest.resource.operation' then
    result := TFhirCapabilityStatementRestResourceOperation.create()
  else if name = 'CapabilityStatement.rest.interaction' then
    result := TFhirCapabilityStatementRestInteraction.create()
  else if name = 'CapabilityStatement.messaging' then
    result := TFhirCapabilityStatementMessaging.create()
  else if name = 'CapabilityStatement.messaging.endpoint' then
    result := TFhirCapabilityStatementMessagingEndpoint.create()
  else if name = 'CapabilityStatement.messaging.supportedMessage' then
    result := TFhirCapabilityStatementMessagingSupportedMessage.create()
  else if name = 'CapabilityStatement.document' then
    result := TFhirCapabilityStatementDocument.create()
  else if name = 'CapabilityStatement' then
    result := TFhirCapabilityStatement.create()
{$ENDIF FHIR_CAPABILITYSTATEMENT}
{$IFDEF FHIR_CAREPLAN}
  else if name = 'CarePlan.activity' then
    result := TFhirCarePlanActivity.create()
  else if name = 'CarePlan.activity.detail' then
    result := TFhirCarePlanActivityDetail.create()
  else if name = 'CarePlan' then
    result := TFhirCarePlan.create()
{$ENDIF FHIR_CAREPLAN}
{$IFDEF FHIR_CARETEAM}
  else if name = 'CareTeam.participant' then
    result := TFhirCareTeamParticipant.create()
  else if name = 'CareTeam' then
    result := TFhirCareTeam.create()
{$ENDIF FHIR_CARETEAM}
{$IFDEF FHIR_CHARGEITEM}
  else if name = 'ChargeItem.performer' then
    result := TFhirChargeItemPerformer.create()
  else if name = 'ChargeItem' then
    result := TFhirChargeItem.create()
{$ENDIF FHIR_CHARGEITEM}
{$IFDEF FHIR_CHARGEITEMDEFINITION}
  else if name = 'ChargeItemDefinition.applicability' then
    result := TFhirChargeItemDefinitionApplicability.create()
  else if name = 'ChargeItemDefinition.propertyGroup' then
    result := TFhirChargeItemDefinitionPropertyGroup.create()
  else if name = 'ChargeItemDefinition.propertyGroup.priceComponent' then
    result := TFhirChargeItemDefinitionPropertyGroupPriceComponent.create()
  else if name = 'ChargeItemDefinition' then
    result := TFhirChargeItemDefinition.create()
{$ENDIF FHIR_CHARGEITEMDEFINITION}
{$IFDEF FHIR_CLAIM}
  else if name = 'Claim.related' then
    result := TFhirClaimRelated.create()
  else if name = 'Claim.payee' then
    result := TFhirClaimPayee.create()
  else if name = 'Claim.careTeam' then
    result := TFhirClaimCareTeam.create()
  else if name = 'Claim.information' then
    result := TFhirClaimInformation.create()
  else if name = 'Claim.diagnosis' then
    result := TFhirClaimDiagnosis.create()
  else if name = 'Claim.procedure' then
    result := TFhirClaimProcedure.create()
  else if name = 'Claim.insurance' then
    result := TFhirClaimInsurance.create()
  else if name = 'Claim.accident' then
    result := TFhirClaimAccident.create()
  else if name = 'Claim.item' then
    result := TFhirClaimItem.create()
  else if name = 'Claim.item.detail' then
    result := TFhirClaimItemDetail.create()
  else if name = 'Claim.item.detail.subDetail' then
    result := TFhirClaimItemDetailSubDetail.create()
  else if name = 'Claim' then
    result := TFhirClaim.create()
{$ENDIF FHIR_CLAIM}
{$IFDEF FHIR_CLAIMRESPONSE}
  else if name = 'ClaimResponse.item' then
    result := TFhirClaimResponseItem.create()
  else if name = 'ClaimResponse.item.adjudication' then
    result := TFhirClaimResponseItemAdjudication.create()
  else if name = 'ClaimResponse.item.detail' then
    result := TFhirClaimResponseItemDetail.create()
  else if name = 'ClaimResponse.item.detail.subDetail' then
    result := TFhirClaimResponseItemDetailSubDetail.create()
  else if name = 'ClaimResponse.addItem' then
    result := TFhirClaimResponseAddItem.create()
  else if name = 'ClaimResponse.error' then
    result := TFhirClaimResponseError.create()
  else if name = 'ClaimResponse.total' then
    result := TFhirClaimResponseTotal.create()
  else if name = 'ClaimResponse.payment' then
    result := TFhirClaimResponsePayment.create()
  else if name = 'ClaimResponse.processNote' then
    result := TFhirClaimResponseProcessNote.create()
  else if name = 'ClaimResponse.insurance' then
    result := TFhirClaimResponseInsurance.create()
  else if name = 'ClaimResponse' then
    result := TFhirClaimResponse.create()
{$ENDIF FHIR_CLAIMRESPONSE}
{$IFDEF FHIR_CLINICALIMPRESSION}
  else if name = 'ClinicalImpression.investigation' then
    result := TFhirClinicalImpressionInvestigation.create()
  else if name = 'ClinicalImpression.finding' then
    result := TFhirClinicalImpressionFinding.create()
  else if name = 'ClinicalImpression' then
    result := TFhirClinicalImpression.create()
{$ENDIF FHIR_CLINICALIMPRESSION}
{$IFDEF FHIR_CODESYSTEM}
  else if name = 'CodeSystem.filter' then
    result := TFhirCodeSystemFilter.create()
  else if name = 'CodeSystem.property' then
    result := TFhirCodeSystemProperty.create()
  else if name = 'CodeSystem.concept' then
    result := TFhirCodeSystemConcept.create()
  else if name = 'CodeSystem.concept.designation' then
    result := TFhirCodeSystemConceptDesignation.create()
  else if name = 'CodeSystem.concept.property' then
    result := TFhirCodeSystemConceptProperty.create()
  else if name = 'CodeSystem' then
    result := TFhirCodeSystem.create()
{$ENDIF FHIR_CODESYSTEM}
{$IFDEF FHIR_COMMUNICATION}
  else if name = 'Communication.payload' then
    result := TFhirCommunicationPayload.create()
  else if name = 'Communication' then
    result := TFhirCommunication.create()
{$ENDIF FHIR_COMMUNICATION}
{$IFDEF FHIR_COMMUNICATIONREQUEST}
  else if name = 'CommunicationRequest.payload' then
    result := TFhirCommunicationRequestPayload.create()
  else if name = 'CommunicationRequest' then
    result := TFhirCommunicationRequest.create()
{$ENDIF FHIR_COMMUNICATIONREQUEST}
{$IFDEF FHIR_COMPARTMENTDEFINITION}
  else if name = 'CompartmentDefinition.resource' then
    result := TFhirCompartmentDefinitionResource.create()
  else if name = 'CompartmentDefinition' then
    result := TFhirCompartmentDefinition.create()
{$ENDIF FHIR_COMPARTMENTDEFINITION}
{$IFDEF FHIR_COMPOSITION}
  else if name = 'Composition.attester' then
    result := TFhirCompositionAttester.create()
  else if name = 'Composition.relatesTo' then
    result := TFhirCompositionRelatesTo.create()
  else if name = 'Composition.event' then
    result := TFhirCompositionEvent.create()
  else if name = 'Composition.section' then
    result := TFhirCompositionSection.create()
  else if name = 'Composition' then
    result := TFhirComposition.create()
{$ENDIF FHIR_COMPOSITION}
{$IFDEF FHIR_CONCEPTMAP}
  else if name = 'ConceptMap.group' then
    result := TFhirConceptMapGroup.create()
  else if name = 'ConceptMap.group.element' then
    result := TFhirConceptMapGroupElement.create()
  else if name = 'ConceptMap.group.element.target' then
    result := TFhirConceptMapGroupElementTarget.create()
  else if name = 'ConceptMap.group.element.target.dependsOn' then
    result := TFhirConceptMapGroupElementTargetDependsOn.create()
  else if name = 'ConceptMap.group.unmapped' then
    result := TFhirConceptMapGroupUnmapped.create()
  else if name = 'ConceptMap' then
    result := TFhirConceptMap.create()
{$ENDIF FHIR_CONCEPTMAP}
{$IFDEF FHIR_CONDITION}
  else if name = 'Condition.stage' then
    result := TFhirConditionStage.create()
  else if name = 'Condition.evidence' then
    result := TFhirConditionEvidence.create()
  else if name = 'Condition' then
    result := TFhirCondition.create()
{$ENDIF FHIR_CONDITION}
{$IFDEF FHIR_CONSENT}
  else if name = 'Consent.policy' then
    result := TFhirConsentPolicy.create()
  else if name = 'Consent.verification' then
    result := TFhirConsentVerification.create()
  else if name = 'Consent.provision' then
    result := TFhirConsentProvision.create()
  else if name = 'Consent.provision.actor' then
    result := TFhirConsentProvisionActor.create()
  else if name = 'Consent.provision.data' then
    result := TFhirConsentProvisionData.create()
  else if name = 'Consent' then
    result := TFhirConsent.create()
{$ENDIF FHIR_CONSENT}
{$IFDEF FHIR_CONTRACT}
  else if name = 'Contract.term' then
    result := TFhirContractTerm.create()
  else if name = 'Contract.term.offer' then
    result := TFhirContractTermOffer.create()
  else if name = 'Contract.term.asset' then
    result := TFhirContractTermAsset.create()
  else if name = 'Contract.term.asset.data' then
    result := TFhirContractTermAssetData.create()
  else if name = 'Contract.term.asset.valuedItem' then
    result := TFhirContractTermAssetValuedItem.create()
  else if name = 'Contract.term.agent' then
    result := TFhirContractTermAgent.create()
  else if name = 'Contract.signer' then
    result := TFhirContractSigner.create()
  else if name = 'Contract.friendly' then
    result := TFhirContractFriendly.create()
  else if name = 'Contract.legal' then
    result := TFhirContractLegal.create()
  else if name = 'Contract.rule' then
    result := TFhirContractRule.create()
  else if name = 'Contract' then
    result := TFhirContract.create()
{$ENDIF FHIR_CONTRACT}
{$IFDEF FHIR_COVERAGE}
  else if name = 'Coverage.class' then
    result := TFhirCoverageClass.create()
  else if name = 'Coverage.copay' then
    result := TFhirCoverageCopay.create()
  else if name = 'Coverage' then
    result := TFhirCoverage.create()
{$ENDIF FHIR_COVERAGE}
{$IFDEF FHIR_DETECTEDISSUE}
  else if name = 'DetectedIssue.mitigation' then
    result := TFhirDetectedIssueMitigation.create()
  else if name = 'DetectedIssue' then
    result := TFhirDetectedIssue.create()
{$ENDIF FHIR_DETECTEDISSUE}
{$IFDEF FHIR_DEVICE}
  else if name = 'Device.udi' then
    result := TFhirDeviceUdi.create()
  else if name = 'Device' then
    result := TFhirDevice.create()
{$ENDIF FHIR_DEVICE}
{$IFDEF FHIR_DEVICECOMPONENT}
  else if name = 'DeviceComponent.productionSpecification' then
    result := TFhirDeviceComponentProductionSpecification.create()
  else if name = 'DeviceComponent.property' then
    result := TFhirDeviceComponentProperty.create()
  else if name = 'DeviceComponent' then
    result := TFhirDeviceComponent.create()
{$ENDIF FHIR_DEVICECOMPONENT}
{$IFDEF FHIR_DEVICEMETRIC}
  else if name = 'DeviceMetric.calibration' then
    result := TFhirDeviceMetricCalibration.create()
  else if name = 'DeviceMetric' then
    result := TFhirDeviceMetric.create()
{$ENDIF FHIR_DEVICEMETRIC}
{$IFDEF FHIR_DEVICEREQUEST}
  else if name = 'DeviceRequest.parameter' then
    result := TFhirDeviceRequestParameter.create()
  else if name = 'DeviceRequest' then
    result := TFhirDeviceRequest.create()
{$ENDIF FHIR_DEVICEREQUEST}
{$IFDEF FHIR_DEVICEUSESTATEMENT}
  else if name = 'DeviceUseStatement' then
    result := TFhirDeviceUseStatement.create()
{$ENDIF FHIR_DEVICEUSESTATEMENT}
{$IFDEF FHIR_DIAGNOSTICREPORT}
  else if name = 'DiagnosticReport.media' then
    result := TFhirDiagnosticReportMedia.create()
  else if name = 'DiagnosticReport' then
    result := TFhirDiagnosticReport.create()
{$ENDIF FHIR_DIAGNOSTICREPORT}
{$IFDEF FHIR_DOCUMENTMANIFEST}
  else if name = 'DocumentManifest.agent' then
    result := TFhirDocumentManifestAgent.create()
  else if name = 'DocumentManifest.related' then
    result := TFhirDocumentManifestRelated.create()
  else if name = 'DocumentManifest' then
    result := TFhirDocumentManifest.create()
{$ENDIF FHIR_DOCUMENTMANIFEST}
{$IFDEF FHIR_DOCUMENTREFERENCE}
  else if name = 'DocumentReference.agent' then
    result := TFhirDocumentReferenceAgent.create()
  else if name = 'DocumentReference.relatesTo' then
    result := TFhirDocumentReferenceRelatesTo.create()
  else if name = 'DocumentReference.content' then
    result := TFhirDocumentReferenceContent.create()
  else if name = 'DocumentReference.context' then
    result := TFhirDocumentReferenceContext.create()
  else if name = 'DocumentReference.context.related' then
    result := TFhirDocumentReferenceContextRelated.create()
  else if name = 'DocumentReference' then
    result := TFhirDocumentReference.create()
{$ENDIF FHIR_DOCUMENTREFERENCE}
{$IFDEF FHIR_ELIGIBILITYREQUEST}
  else if name = 'EligibilityRequest.authorization' then
    result := TFhirEligibilityRequestAuthorization.create()
  else if name = 'EligibilityRequest.authorization.diagnosis' then
    result := TFhirEligibilityRequestAuthorizationDiagnosis.create()
  else if name = 'EligibilityRequest' then
    result := TFhirEligibilityRequest.create()
{$ENDIF FHIR_ELIGIBILITYREQUEST}
{$IFDEF FHIR_ELIGIBILITYRESPONSE}
  else if name = 'EligibilityResponse.insurance' then
    result := TFhirEligibilityResponseInsurance.create()
  else if name = 'EligibilityResponse.insurance.benefitBalance' then
    result := TFhirEligibilityResponseInsuranceBenefitBalance.create()
  else if name = 'EligibilityResponse.insurance.benefitBalance.financial' then
    result := TFhirEligibilityResponseInsuranceBenefitBalanceFinancial.create()
  else if name = 'EligibilityResponse.authorization' then
    result := TFhirEligibilityResponseAuthorization.create()
  else if name = 'EligibilityResponse.error' then
    result := TFhirEligibilityResponseError.create()
  else if name = 'EligibilityResponse' then
    result := TFhirEligibilityResponse.create()
{$ENDIF FHIR_ELIGIBILITYRESPONSE}
{$IFDEF FHIR_ENCOUNTER}
  else if name = 'Encounter.statusHistory' then
    result := TFhirEncounterStatusHistory.create()
  else if name = 'Encounter.classHistory' then
    result := TFhirEncounterClassHistory.create()
  else if name = 'Encounter.participant' then
    result := TFhirEncounterParticipant.create()
  else if name = 'Encounter.diagnosis' then
    result := TFhirEncounterDiagnosis.create()
  else if name = 'Encounter.hospitalization' then
    result := TFhirEncounterHospitalization.create()
  else if name = 'Encounter.location' then
    result := TFhirEncounterLocation.create()
  else if name = 'Encounter' then
    result := TFhirEncounter.create()
{$ENDIF FHIR_ENCOUNTER}
{$IFDEF FHIR_ENDPOINT}
  else if name = 'Endpoint' then
    result := TFhirEndpoint.create()
{$ENDIF FHIR_ENDPOINT}
{$IFDEF FHIR_ENROLLMENTREQUEST}
  else if name = 'EnrollmentRequest' then
    result := TFhirEnrollmentRequest.create()
{$ENDIF FHIR_ENROLLMENTREQUEST}
{$IFDEF FHIR_ENROLLMENTRESPONSE}
  else if name = 'EnrollmentResponse' then
    result := TFhirEnrollmentResponse.create()
{$ENDIF FHIR_ENROLLMENTRESPONSE}
{$IFDEF FHIR_ENTRYDEFINITION}
  else if name = 'EntryDefinition.relatedEntry' then
    result := TFhirEntryDefinitionRelatedEntry.create()
  else if name = 'EntryDefinition' then
    result := TFhirEntryDefinition.create()
{$ENDIF FHIR_ENTRYDEFINITION}
{$IFDEF FHIR_EPISODEOFCARE}
  else if name = 'EpisodeOfCare.statusHistory' then
    result := TFhirEpisodeOfCareStatusHistory.create()
  else if name = 'EpisodeOfCare.diagnosis' then
    result := TFhirEpisodeOfCareDiagnosis.create()
  else if name = 'EpisodeOfCare' then
    result := TFhirEpisodeOfCare.create()
{$ENDIF FHIR_EPISODEOFCARE}
{$IFDEF FHIR_EVENTDEFINITION}
  else if name = 'EventDefinition' then
    result := TFhirEventDefinition.create()
{$ENDIF FHIR_EVENTDEFINITION}
{$IFDEF FHIR_EXAMPLESCENARIO}
  else if name = 'ExampleScenario.actor' then
    result := TFhirExampleScenarioActor.create()
  else if name = 'ExampleScenario.instance' then
    result := TFhirExampleScenarioInstance.create()
  else if name = 'ExampleScenario.instance.version' then
    result := TFhirExampleScenarioInstanceVersion.create()
  else if name = 'ExampleScenario.instance.containedInstance' then
    result := TFhirExampleScenarioInstanceContainedInstance.create()
  else if name = 'ExampleScenario.process' then
    result := TFhirExampleScenarioProcess.create()
  else if name = 'ExampleScenario.process.step' then
    result := TFhirExampleScenarioProcessStep.create()
  else if name = 'ExampleScenario.process.step.operation' then
    result := TFhirExampleScenarioProcessStepOperation.create()
  else if name = 'ExampleScenario.process.step.alternative' then
    result := TFhirExampleScenarioProcessStepAlternative.create()
  else if name = 'ExampleScenario.process.step.alternative.option' then
    result := TFhirExampleScenarioProcessStepAlternativeOption.create()
  else if name = 'ExampleScenario' then
    result := TFhirExampleScenario.create()
{$ENDIF FHIR_EXAMPLESCENARIO}
{$IFDEF FHIR_EXPANSIONPROFILE}
  else if name = 'ExpansionProfile.fixedVersion' then
    result := TFhirExpansionProfileFixedVersion.create()
  else if name = 'ExpansionProfile.excludedSystem' then
    result := TFhirExpansionProfileExcludedSystem.create()
  else if name = 'ExpansionProfile.designation' then
    result := TFhirExpansionProfileDesignation.create()
  else if name = 'ExpansionProfile.designation.include' then
    result := TFhirExpansionProfileDesignationInclude.create()
  else if name = 'ExpansionProfile.designation.include.designation' then
    result := TFhirExpansionProfileDesignationIncludeDesignation.create()
  else if name = 'ExpansionProfile.designation.exclude' then
    result := TFhirExpansionProfileDesignationExclude.create()
  else if name = 'ExpansionProfile.designation.exclude.designation' then
    result := TFhirExpansionProfileDesignationExcludeDesignation.create()
  else if name = 'ExpansionProfile' then
    result := TFhirExpansionProfile.create()
{$ENDIF FHIR_EXPANSIONPROFILE}
{$IFDEF FHIR_EXPLANATIONOFBENEFIT}
  else if name = 'ExplanationOfBenefit.related' then
    result := TFhirExplanationOfBenefitRelated.create()
  else if name = 'ExplanationOfBenefit.payee' then
    result := TFhirExplanationOfBenefitPayee.create()
  else if name = 'ExplanationOfBenefit.information' then
    result := TFhirExplanationOfBenefitInformation.create()
  else if name = 'ExplanationOfBenefit.careTeam' then
    result := TFhirExplanationOfBenefitCareTeam.create()
  else if name = 'ExplanationOfBenefit.diagnosis' then
    result := TFhirExplanationOfBenefitDiagnosis.create()
  else if name = 'ExplanationOfBenefit.procedure' then
    result := TFhirExplanationOfBenefitProcedure.create()
  else if name = 'ExplanationOfBenefit.insurance' then
    result := TFhirExplanationOfBenefitInsurance.create()
  else if name = 'ExplanationOfBenefit.accident' then
    result := TFhirExplanationOfBenefitAccident.create()
  else if name = 'ExplanationOfBenefit.item' then
    result := TFhirExplanationOfBenefitItem.create()
  else if name = 'ExplanationOfBenefit.item.adjudication' then
    result := TFhirExplanationOfBenefitItemAdjudication.create()
  else if name = 'ExplanationOfBenefit.item.detail' then
    result := TFhirExplanationOfBenefitItemDetail.create()
  else if name = 'ExplanationOfBenefit.item.detail.subDetail' then
    result := TFhirExplanationOfBenefitItemDetailSubDetail.create()
  else if name = 'ExplanationOfBenefit.addItem' then
    result := TFhirExplanationOfBenefitAddItem.create()
  else if name = 'ExplanationOfBenefit.total' then
    result := TFhirExplanationOfBenefitTotal.create()
  else if name = 'ExplanationOfBenefit.payment' then
    result := TFhirExplanationOfBenefitPayment.create()
  else if name = 'ExplanationOfBenefit.processNote' then
    result := TFhirExplanationOfBenefitProcessNote.create()
  else if name = 'ExplanationOfBenefit.benefitBalance' then
    result := TFhirExplanationOfBenefitBenefitBalance.create()
  else if name = 'ExplanationOfBenefit.benefitBalance.financial' then
    result := TFhirExplanationOfBenefitBenefitBalanceFinancial.create()
  else if name = 'ExplanationOfBenefit' then
    result := TFhirExplanationOfBenefit.create()
{$ENDIF FHIR_EXPLANATIONOFBENEFIT}
{$IFDEF FHIR_FAMILYMEMBERHISTORY}
  else if name = 'FamilyMemberHistory.condition' then
    result := TFhirFamilyMemberHistoryCondition.create()
  else if name = 'FamilyMemberHistory' then
    result := TFhirFamilyMemberHistory.create()
{$ENDIF FHIR_FAMILYMEMBERHISTORY}
{$IFDEF FHIR_FLAG}
  else if name = 'Flag' then
    result := TFhirFlag.create()
{$ENDIF FHIR_FLAG}
{$IFDEF FHIR_GOAL}
  else if name = 'Goal.target' then
    result := TFhirGoalTarget.create()
  else if name = 'Goal' then
    result := TFhirGoal.create()
{$ENDIF FHIR_GOAL}
{$IFDEF FHIR_GRAPHDEFINITION}
  else if name = 'GraphDefinition.link' then
    result := TFhirGraphDefinitionLink.create()
  else if name = 'GraphDefinition.link.target' then
    result := TFhirGraphDefinitionLinkTarget.create()
  else if name = 'GraphDefinition.link.target.compartment' then
    result := TFhirGraphDefinitionLinkTargetCompartment.create()
  else if name = 'GraphDefinition' then
    result := TFhirGraphDefinition.create()
{$ENDIF FHIR_GRAPHDEFINITION}
{$IFDEF FHIR_GROUP}
  else if name = 'Group.characteristic' then
    result := TFhirGroupCharacteristic.create()
  else if name = 'Group.member' then
    result := TFhirGroupMember.create()
  else if name = 'Group' then
    result := TFhirGroup.create()
{$ENDIF FHIR_GROUP}
{$IFDEF FHIR_GUIDANCERESPONSE}
  else if name = 'GuidanceResponse' then
    result := TFhirGuidanceResponse.create()
{$ENDIF FHIR_GUIDANCERESPONSE}
{$IFDEF FHIR_HEALTHCARESERVICE}
  else if name = 'HealthcareService.availableTime' then
    result := TFhirHealthcareServiceAvailableTime.create()
  else if name = 'HealthcareService.notAvailable' then
    result := TFhirHealthcareServiceNotAvailable.create()
  else if name = 'HealthcareService' then
    result := TFhirHealthcareService.create()
{$ENDIF FHIR_HEALTHCARESERVICE}
{$IFDEF FHIR_IMAGINGSTUDY}
  else if name = 'ImagingStudy.series' then
    result := TFhirImagingStudySeries.create()
  else if name = 'ImagingStudy.series.performer' then
    result := TFhirImagingStudySeriesPerformer.create()
  else if name = 'ImagingStudy.series.instance' then
    result := TFhirImagingStudySeriesInstance.create()
  else if name = 'ImagingStudy' then
    result := TFhirImagingStudy.create()
{$ENDIF FHIR_IMAGINGSTUDY}
{$IFDEF FHIR_IMMUNIZATION}
  else if name = 'Immunization.performer' then
    result := TFhirImmunizationPerformer.create()
  else if name = 'Immunization.education' then
    result := TFhirImmunizationEducation.create()
  else if name = 'Immunization' then
    result := TFhirImmunization.create()
{$ENDIF FHIR_IMMUNIZATION}
{$IFDEF FHIR_IMMUNIZATIONEVALUATION}
  else if name = 'ImmunizationEvaluation' then
    result := TFhirImmunizationEvaluation.create()
{$ENDIF FHIR_IMMUNIZATIONEVALUATION}
{$IFDEF FHIR_IMMUNIZATIONRECOMMENDATION}
  else if name = 'ImmunizationRecommendation.recommendation' then
    result := TFhirImmunizationRecommendationRecommendation.create()
  else if name = 'ImmunizationRecommendation.recommendation.dateCriterion' then
    result := TFhirImmunizationRecommendationRecommendationDateCriterion.create()
  else if name = 'ImmunizationRecommendation' then
    result := TFhirImmunizationRecommendation.create()
{$ENDIF FHIR_IMMUNIZATIONRECOMMENDATION}
{$IFDEF FHIR_IMPLEMENTATIONGUIDE}
  else if name = 'ImplementationGuide.dependsOn' then
    result := TFhirImplementationGuideDependsOn.create()
  else if name = 'ImplementationGuide.global' then
    result := TFhirImplementationGuideGlobal.create()
  else if name = 'ImplementationGuide.definition' then
    result := TFhirImplementationGuideDefinition.create()
  else if name = 'ImplementationGuide.definition.package' then
    result := TFhirImplementationGuideDefinitionPackage.create()
  else if name = 'ImplementationGuide.definition.resource' then
    result := TFhirImplementationGuideDefinitionResource.create()
  else if name = 'ImplementationGuide.definition.page' then
    result := TFhirImplementationGuideDefinitionPage.create()
  else if name = 'ImplementationGuide.definition.parameter' then
    result := TFhirImplementationGuideDefinitionParameter.create()
  else if name = 'ImplementationGuide.definition.template' then
    result := TFhirImplementationGuideDefinitionTemplate.create()
  else if name = 'ImplementationGuide.manifest' then
    result := TFhirImplementationGuideManifest.create()
  else if name = 'ImplementationGuide.manifest.resource' then
    result := TFhirImplementationGuideManifestResource.create()
  else if name = 'ImplementationGuide.manifest.page' then
    result := TFhirImplementationGuideManifestPage.create()
  else if name = 'ImplementationGuide' then
    result := TFhirImplementationGuide.create()
{$ENDIF FHIR_IMPLEMENTATIONGUIDE}
{$IFDEF FHIR_INVOICE}
  else if name = 'Invoice.participant' then
    result := TFhirInvoiceParticipant.create()
  else if name = 'Invoice.lineItem' then
    result := TFhirInvoiceLineItem.create()
  else if name = 'Invoice.lineItem.priceComponent' then
    result := TFhirInvoiceLineItemPriceComponent.create()
  else if name = 'Invoice' then
    result := TFhirInvoice.create()
{$ENDIF FHIR_INVOICE}
{$IFDEF FHIR_ITEMINSTANCE}
  else if name = 'ItemInstance' then
    result := TFhirItemInstance.create()
{$ENDIF FHIR_ITEMINSTANCE}
{$IFDEF FHIR_LIBRARY}
  else if name = 'Library' then
    result := TFhirLibrary.create()
{$ENDIF FHIR_LIBRARY}
{$IFDEF FHIR_LINKAGE}
  else if name = 'Linkage.item' then
    result := TFhirLinkageItem.create()
  else if name = 'Linkage' then
    result := TFhirLinkage.create()
{$ENDIF FHIR_LINKAGE}
{$IFDEF FHIR_LIST}
  else if name = 'List.entry' then
    result := TFhirListEntry.create()
  else if name = 'List' then
    result := TFhirList.create()
{$ENDIF FHIR_LIST}
{$IFDEF FHIR_LOCATION}
  else if name = 'Location.position' then
    result := TFhirLocationPosition.create()
  else if name = 'Location.hoursOfOperation' then
    result := TFhirLocationHoursOfOperation.create()
  else if name = 'Location' then
    result := TFhirLocation.create()
{$ENDIF FHIR_LOCATION}
{$IFDEF FHIR_MEASURE}
  else if name = 'Measure.group' then
    result := TFhirMeasureGroup.create()
  else if name = 'Measure.group.population' then
    result := TFhirMeasureGroupPopulation.create()
  else if name = 'Measure.group.stratifier' then
    result := TFhirMeasureGroupStratifier.create()
  else if name = 'Measure.supplementalData' then
    result := TFhirMeasureSupplementalData.create()
  else if name = 'Measure' then
    result := TFhirMeasure.create()
{$ENDIF FHIR_MEASURE}
{$IFDEF FHIR_MEASUREREPORT}
  else if name = 'MeasureReport.group' then
    result := TFhirMeasureReportGroup.create()
  else if name = 'MeasureReport.group.population' then
    result := TFhirMeasureReportGroupPopulation.create()
  else if name = 'MeasureReport.group.stratifier' then
    result := TFhirMeasureReportGroupStratifier.create()
  else if name = 'MeasureReport.group.stratifier.stratum' then
    result := TFhirMeasureReportGroupStratifierStratum.create()
  else if name = 'MeasureReport.group.stratifier.stratum.population' then
    result := TFhirMeasureReportGroupStratifierStratumPopulation.create()
  else if name = 'MeasureReport' then
    result := TFhirMeasureReport.create()
{$ENDIF FHIR_MEASUREREPORT}
{$IFDEF FHIR_MEDIA}
  else if name = 'Media' then
    result := TFhirMedia.create()
{$ENDIF FHIR_MEDIA}
{$IFDEF FHIR_MEDICATION}
  else if name = 'Medication.ingredient' then
    result := TFhirMedicationIngredient.create()
  else if name = 'Medication.batch' then
    result := TFhirMedicationBatch.create()
  else if name = 'Medication' then
    result := TFhirMedication.create()
{$ENDIF FHIR_MEDICATION}
{$IFDEF FHIR_MEDICATIONADMINISTRATION}
  else if name = 'MedicationAdministration.performer' then
    result := TFhirMedicationAdministrationPerformer.create()
  else if name = 'MedicationAdministration.dosage' then
    result := TFhirMedicationAdministrationDosage.create()
  else if name = 'MedicationAdministration' then
    result := TFhirMedicationAdministration.create()
{$ENDIF FHIR_MEDICATIONADMINISTRATION}
{$IFDEF FHIR_MEDICATIONDISPENSE}
  else if name = 'MedicationDispense.performer' then
    result := TFhirMedicationDispensePerformer.create()
  else if name = 'MedicationDispense.substitution' then
    result := TFhirMedicationDispenseSubstitution.create()
  else if name = 'MedicationDispense' then
    result := TFhirMedicationDispense.create()
{$ENDIF FHIR_MEDICATIONDISPENSE}
{$IFDEF FHIR_MEDICATIONKNOWLEDGE}
  else if name = 'MedicationKnowledge.monograph' then
    result := TFhirMedicationKnowledgeMonograph.create()
  else if name = 'MedicationKnowledge.ingredient' then
    result := TFhirMedicationKnowledgeIngredient.create()
  else if name = 'MedicationKnowledge.cost' then
    result := TFhirMedicationKnowledgeCost.create()
  else if name = 'MedicationKnowledge.monitoringProgram' then
    result := TFhirMedicationKnowledgeMonitoringProgram.create()
  else if name = 'MedicationKnowledge.administrationGuidelines' then
    result := TFhirMedicationKnowledgeAdministrationGuidelines.create()
  else if name = 'MedicationKnowledge.administrationGuidelines.patientCharacteristics' then
    result := TFhirMedicationKnowledgeAdministrationGuidelinesPatientCharacteristics.create()
  else if name = 'MedicationKnowledge.medicineClassification' then
    result := TFhirMedicationKnowledgeMedicineClassification.create()
  else if name = 'MedicationKnowledge.packaging' then
    result := TFhirMedicationKnowledgePackaging.create()
  else if name = 'MedicationKnowledge.drugCharacteristic' then
    result := TFhirMedicationKnowledgeDrugCharacteristic.create()
  else if name = 'MedicationKnowledge' then
    result := TFhirMedicationKnowledge.create()
{$ENDIF FHIR_MEDICATIONKNOWLEDGE}
{$IFDEF FHIR_MEDICATIONREQUEST}
  else if name = 'MedicationRequest.dispenseRequest' then
    result := TFhirMedicationRequestDispenseRequest.create()
  else if name = 'MedicationRequest.substitution' then
    result := TFhirMedicationRequestSubstitution.create()
  else if name = 'MedicationRequest' then
    result := TFhirMedicationRequest.create()
{$ENDIF FHIR_MEDICATIONREQUEST}
{$IFDEF FHIR_MEDICATIONSTATEMENT}
  else if name = 'MedicationStatement' then
    result := TFhirMedicationStatement.create()
{$ENDIF FHIR_MEDICATIONSTATEMENT}
{$IFDEF FHIR_MEDICINALPRODUCT}
  else if name = 'MedicinalProduct.name' then
    result := TFhirMedicinalProductName.create()
  else if name = 'MedicinalProduct.name.namePart' then
    result := TFhirMedicinalProductNameNamePart.create()
  else if name = 'MedicinalProduct.name.countryLanguage' then
    result := TFhirMedicinalProductNameCountryLanguage.create()
  else if name = 'MedicinalProduct.manufacturingBusinessOperation' then
    result := TFhirMedicinalProductManufacturingBusinessOperation.create()
  else if name = 'MedicinalProduct' then
    result := TFhirMedicinalProduct.create()
{$ENDIF FHIR_MEDICINALPRODUCT}
{$IFDEF FHIR_MEDICINALPRODUCTAUTHORIZATION}
  else if name = 'MedicinalProductAuthorization.jurisdictionalAuthorization' then
    result := TFhirMedicinalProductAuthorizationJurisdictionalAuthorization.create()
  else if name = 'MedicinalProductAuthorization.procedure' then
    result := TFhirMedicinalProductAuthorizationProcedure.create()
  else if name = 'MedicinalProductAuthorization.procedure.application' then
    result := TFhirMedicinalProductAuthorizationProcedureApplication.create()
  else if name = 'MedicinalProductAuthorization' then
    result := TFhirMedicinalProductAuthorization.create()
{$ENDIF FHIR_MEDICINALPRODUCTAUTHORIZATION}
{$IFDEF FHIR_MEDICINALPRODUCTCLINICALS}
  else if name = 'MedicinalProductClinicals.undesirableEffects' then
    result := TFhirMedicinalProductClinicalsUndesirableEffects.create()
  else if name = 'MedicinalProductClinicals.undesirableEffects.population' then
    result := TFhirMedicinalProductClinicalsUndesirableEffectsPopulation.create()
  else if name = 'MedicinalProductClinicals.therapeuticIndication' then
    result := TFhirMedicinalProductClinicalsTherapeuticIndication.create()
  else if name = 'MedicinalProductClinicals.therapeuticIndication.otherTherapy' then
    result := TFhirMedicinalProductClinicalsTherapeuticIndicationOtherTherapy.create()
  else if name = 'MedicinalProductClinicals.contraindication' then
    result := TFhirMedicinalProductClinicalsContraindication.create()
  else if name = 'MedicinalProductClinicals.interactions' then
    result := TFhirMedicinalProductClinicalsInteractions.create()
  else if name = 'MedicinalProductClinicals' then
    result := TFhirMedicinalProductClinicals.create()
{$ENDIF FHIR_MEDICINALPRODUCTCLINICALS}
{$IFDEF FHIR_MEDICINALPRODUCTDEVICESPEC}
  else if name = 'MedicinalProductDeviceSpec.material' then
    result := TFhirMedicinalProductDeviceSpecMaterial.create()
  else if name = 'MedicinalProductDeviceSpec' then
    result := TFhirMedicinalProductDeviceSpec.create()
{$ENDIF FHIR_MEDICINALPRODUCTDEVICESPEC}
{$IFDEF FHIR_MEDICINALPRODUCTINGREDIENT}
  else if name = 'MedicinalProductIngredient.specifiedSubstance' then
    result := TFhirMedicinalProductIngredientSpecifiedSubstance.create()
  else if name = 'MedicinalProductIngredient.specifiedSubstance.strength' then
    result := TFhirMedicinalProductIngredientSpecifiedSubstanceStrength.create()
  else if name = 'MedicinalProductIngredient.specifiedSubstance.strength.referenceStrength' then
    result := TFhirMedicinalProductIngredientSpecifiedSubstanceStrengthReferenceStrength.create()
  else if name = 'MedicinalProductIngredient.substance' then
    result := TFhirMedicinalProductIngredientSubstance.create()
  else if name = 'MedicinalProductIngredient' then
    result := TFhirMedicinalProductIngredient.create()
{$ENDIF FHIR_MEDICINALPRODUCTINGREDIENT}
{$IFDEF FHIR_MEDICINALPRODUCTPACKAGED}
  else if name = 'MedicinalProductPackaged.batchIdentifier' then
    result := TFhirMedicinalProductPackagedBatchIdentifier.create()
  else if name = 'MedicinalProductPackaged.packageItem' then
    result := TFhirMedicinalProductPackagedPackageItem.create()
  else if name = 'MedicinalProductPackaged.packageItem.manufacturedItem' then
    result := TFhirMedicinalProductPackagedPackageItemManufacturedItem.create()
  else if name = 'MedicinalProductPackaged' then
    result := TFhirMedicinalProductPackaged.create()
{$ENDIF FHIR_MEDICINALPRODUCTPACKAGED}
{$IFDEF FHIR_MEDICINALPRODUCTPHARMACEUTICAL}
  else if name = 'MedicinalProductPharmaceutical.characteristics' then
    result := TFhirMedicinalProductPharmaceuticalCharacteristics.create()
  else if name = 'MedicinalProductPharmaceutical' then
    result := TFhirMedicinalProductPharmaceutical.create()
{$ENDIF FHIR_MEDICINALPRODUCTPHARMACEUTICAL}
{$IFDEF FHIR_MESSAGEDEFINITION}
  else if name = 'MessageDefinition.focus' then
    result := TFhirMessageDefinitionFocus.create()
  else if name = 'MessageDefinition.allowedResponse' then
    result := TFhirMessageDefinitionAllowedResponse.create()
  else if name = 'MessageDefinition' then
    result := TFhirMessageDefinition.create()
{$ENDIF FHIR_MESSAGEDEFINITION}
{$IFDEF FHIR_MESSAGEHEADER}
  else if name = 'MessageHeader.destination' then
    result := TFhirMessageHeaderDestination.create()
  else if name = 'MessageHeader.source' then
    result := TFhirMessageHeaderSource.create()
  else if name = 'MessageHeader.response' then
    result := TFhirMessageHeaderResponse.create()
  else if name = 'MessageHeader' then
    result := TFhirMessageHeader.create()
{$ENDIF FHIR_MESSAGEHEADER}
{$IFDEF FHIR_NAMINGSYSTEM}
  else if name = 'NamingSystem.uniqueId' then
    result := TFhirNamingSystemUniqueId.create()
  else if name = 'NamingSystem' then
    result := TFhirNamingSystem.create()
{$ENDIF FHIR_NAMINGSYSTEM}
{$IFDEF FHIR_NUTRITIONORDER}
  else if name = 'NutritionOrder.oralDiet' then
    result := TFhirNutritionOrderOralDiet.create()
  else if name = 'NutritionOrder.oralDiet.nutrient' then
    result := TFhirNutritionOrderOralDietNutrient.create()
  else if name = 'NutritionOrder.oralDiet.texture' then
    result := TFhirNutritionOrderOralDietTexture.create()
  else if name = 'NutritionOrder.supplement' then
    result := TFhirNutritionOrderSupplement.create()
  else if name = 'NutritionOrder.enteralFormula' then
    result := TFhirNutritionOrderEnteralFormula.create()
  else if name = 'NutritionOrder.enteralFormula.administration' then
    result := TFhirNutritionOrderEnteralFormulaAdministration.create()
  else if name = 'NutritionOrder' then
    result := TFhirNutritionOrder.create()
{$ENDIF FHIR_NUTRITIONORDER}
{$IFDEF FHIR_OBSERVATION}
  else if name = 'Observation.referenceRange' then
    result := TFhirObservationReferenceRange.create()
  else if name = 'Observation.component' then
    result := TFhirObservationComponent.create()
  else if name = 'Observation' then
    result := TFhirObservation.create()
{$ENDIF FHIR_OBSERVATION}
{$IFDEF FHIR_OBSERVATIONDEFINITION}
  else if name = 'ObservationDefinition.quantitativeDetails' then
    result := TFhirObservationDefinitionQuantitativeDetails.create()
  else if name = 'ObservationDefinition.qualifiedInterval' then
    result := TFhirObservationDefinitionQualifiedInterval.create()
  else if name = 'ObservationDefinition' then
    result := TFhirObservationDefinition.create()
{$ENDIF FHIR_OBSERVATIONDEFINITION}
{$IFDEF FHIR_OCCUPATIONALDATA}
  else if name = 'OccupationalData.employmentStatus' then
    result := TFhirOccupationalDataEmploymentStatus.create()
  else if name = 'OccupationalData.usualWork' then
    result := TFhirOccupationalDataUsualWork.create()
  else if name = 'OccupationalData.pastOrPresentJob' then
    result := TFhirOccupationalDataPastOrPresentJob.create()
  else if name = 'OccupationalData.pastOrPresentJob.workSchedule' then
    result := TFhirOccupationalDataPastOrPresentJobWorkSchedule.create()
  else if name = 'OccupationalData' then
    result := TFhirOccupationalData.create()
{$ENDIF FHIR_OCCUPATIONALDATA}
{$IFDEF FHIR_OPERATIONDEFINITION}
  else if name = 'OperationDefinition.parameter' then
    result := TFhirOperationDefinitionParameter.create()
  else if name = 'OperationDefinition.parameter.binding' then
    result := TFhirOperationDefinitionParameterBinding.create()
  else if name = 'OperationDefinition.overload' then
    result := TFhirOperationDefinitionOverload.create()
  else if name = 'OperationDefinition' then
    result := TFhirOperationDefinition.create()
{$ENDIF FHIR_OPERATIONDEFINITION}
{$IFDEF FHIR_OPERATIONOUTCOME}
  else if name = 'OperationOutcome.issue' then
    result := TFhirOperationOutcomeIssue.create()
  else if name = 'OperationOutcome' then
    result := TFhirOperationOutcome.create()
{$ENDIF FHIR_OPERATIONOUTCOME}
{$IFDEF FHIR_ORGANIZATION}
  else if name = 'Organization.contact' then
    result := TFhirOrganizationContact.create()
  else if name = 'Organization' then
    result := TFhirOrganization.create()
{$ENDIF FHIR_ORGANIZATION}
{$IFDEF FHIR_ORGANIZATIONROLE}
  else if name = 'OrganizationRole.availableTime' then
    result := TFhirOrganizationRoleAvailableTime.create()
  else if name = 'OrganizationRole.notAvailable' then
    result := TFhirOrganizationRoleNotAvailable.create()
  else if name = 'OrganizationRole' then
    result := TFhirOrganizationRole.create()
{$ENDIF FHIR_ORGANIZATIONROLE}
{$IFDEF FHIR_PATIENT}
  else if name = 'Patient.contact' then
    result := TFhirPatientContact.create()
  else if name = 'Patient.communication' then
    result := TFhirPatientCommunication.create()
  else if name = 'Patient.link' then
    result := TFhirPatientLink.create()
  else if name = 'Patient' then
    result := TFhirPatient.create()
{$ENDIF FHIR_PATIENT}
{$IFDEF FHIR_PAYMENTNOTICE}
  else if name = 'PaymentNotice' then
    result := TFhirPaymentNotice.create()
{$ENDIF FHIR_PAYMENTNOTICE}
{$IFDEF FHIR_PAYMENTRECONCILIATION}
  else if name = 'PaymentReconciliation.detail' then
    result := TFhirPaymentReconciliationDetail.create()
  else if name = 'PaymentReconciliation.processNote' then
    result := TFhirPaymentReconciliationProcessNote.create()
  else if name = 'PaymentReconciliation' then
    result := TFhirPaymentReconciliation.create()
{$ENDIF FHIR_PAYMENTRECONCILIATION}
{$IFDEF FHIR_PERSON}
  else if name = 'Person.link' then
    result := TFhirPersonLink.create()
  else if name = 'Person' then
    result := TFhirPerson.create()
{$ENDIF FHIR_PERSON}
{$IFDEF FHIR_PLANDEFINITION}
  else if name = 'PlanDefinition.goal' then
    result := TFhirPlanDefinitionGoal.create()
  else if name = 'PlanDefinition.goal.target' then
    result := TFhirPlanDefinitionGoalTarget.create()
  else if name = 'PlanDefinition.action' then
    result := TFhirPlanDefinitionAction.create()
  else if name = 'PlanDefinition.action.condition' then
    result := TFhirPlanDefinitionActionCondition.create()
  else if name = 'PlanDefinition.action.relatedAction' then
    result := TFhirPlanDefinitionActionRelatedAction.create()
  else if name = 'PlanDefinition.action.participant' then
    result := TFhirPlanDefinitionActionParticipant.create()
  else if name = 'PlanDefinition.action.dynamicValue' then
    result := TFhirPlanDefinitionActionDynamicValue.create()
  else if name = 'PlanDefinition' then
    result := TFhirPlanDefinition.create()
{$ENDIF FHIR_PLANDEFINITION}
{$IFDEF FHIR_PRACTITIONER}
  else if name = 'Practitioner.qualification' then
    result := TFhirPractitionerQualification.create()
  else if name = 'Practitioner' then
    result := TFhirPractitioner.create()
{$ENDIF FHIR_PRACTITIONER}
{$IFDEF FHIR_PRACTITIONERROLE}
  else if name = 'PractitionerRole.availableTime' then
    result := TFhirPractitionerRoleAvailableTime.create()
  else if name = 'PractitionerRole.notAvailable' then
    result := TFhirPractitionerRoleNotAvailable.create()
  else if name = 'PractitionerRole' then
    result := TFhirPractitionerRole.create()
{$ENDIF FHIR_PRACTITIONERROLE}
{$IFDEF FHIR_PROCEDURE}
  else if name = 'Procedure.performer' then
    result := TFhirProcedurePerformer.create()
  else if name = 'Procedure.focalDevice' then
    result := TFhirProcedureFocalDevice.create()
  else if name = 'Procedure' then
    result := TFhirProcedure.create()
{$ENDIF FHIR_PROCEDURE}
{$IFDEF FHIR_PROCESSREQUEST}
  else if name = 'ProcessRequest.item' then
    result := TFhirProcessRequestItem.create()
  else if name = 'ProcessRequest' then
    result := TFhirProcessRequest.create()
{$ENDIF FHIR_PROCESSREQUEST}
{$IFDEF FHIR_PROCESSRESPONSE}
  else if name = 'ProcessResponse.processNote' then
    result := TFhirProcessResponseProcessNote.create()
  else if name = 'ProcessResponse' then
    result := TFhirProcessResponse.create()
{$ENDIF FHIR_PROCESSRESPONSE}
{$IFDEF FHIR_PRODUCTPLAN}
  else if name = 'ProductPlan.contact' then
    result := TFhirProductPlanContact.create()
  else if name = 'ProductPlan.coverage' then
    result := TFhirProductPlanCoverage.create()
  else if name = 'ProductPlan.coverage.benefit' then
    result := TFhirProductPlanCoverageBenefit.create()
  else if name = 'ProductPlan.coverage.benefit.limit' then
    result := TFhirProductPlanCoverageBenefitLimit.create()
  else if name = 'ProductPlan.plan' then
    result := TFhirProductPlanPlan.create()
  else if name = 'ProductPlan.plan.generalCost' then
    result := TFhirProductPlanPlanGeneralCost.create()
  else if name = 'ProductPlan.plan.specificCost' then
    result := TFhirProductPlanPlanSpecificCost.create()
  else if name = 'ProductPlan.plan.specificCost.benefit' then
    result := TFhirProductPlanPlanSpecificCostBenefit.create()
  else if name = 'ProductPlan.plan.specificCost.benefit.cost' then
    result := TFhirProductPlanPlanSpecificCostBenefitCost.create()
  else if name = 'ProductPlan' then
    result := TFhirProductPlan.create()
{$ENDIF FHIR_PRODUCTPLAN}
{$IFDEF FHIR_PROVENANCE}
  else if name = 'Provenance.agent' then
    result := TFhirProvenanceAgent.create()
  else if name = 'Provenance.entity' then
    result := TFhirProvenanceEntity.create()
  else if name = 'Provenance' then
    result := TFhirProvenance.create()
{$ENDIF FHIR_PROVENANCE}
{$IFDEF FHIR_QUESTIONNAIRE}
  else if name = 'Questionnaire.item' then
    result := TFhirQuestionnaireItem.create()
  else if name = 'Questionnaire.item.enableWhen' then
    result := TFhirQuestionnaireItemEnableWhen.create()
  else if name = 'Questionnaire.item.option' then
    result := TFhirQuestionnaireItemOption.create()
  else if name = 'Questionnaire.item.initial' then
    result := TFhirQuestionnaireItemInitial.create()
  else if name = 'Questionnaire' then
    result := TFhirQuestionnaire.create()
{$ENDIF FHIR_QUESTIONNAIRE}
{$IFDEF FHIR_QUESTIONNAIRERESPONSE}
  else if name = 'QuestionnaireResponse.item' then
    result := TFhirQuestionnaireResponseItem.create()
  else if name = 'QuestionnaireResponse.item.answer' then
    result := TFhirQuestionnaireResponseItemAnswer.create()
  else if name = 'QuestionnaireResponse' then
    result := TFhirQuestionnaireResponse.create()
{$ENDIF FHIR_QUESTIONNAIRERESPONSE}
{$IFDEF FHIR_RELATEDPERSON}
  else if name = 'RelatedPerson' then
    result := TFhirRelatedPerson.create()
{$ENDIF FHIR_RELATEDPERSON}
{$IFDEF FHIR_REQUESTGROUP}
  else if name = 'RequestGroup.action' then
    result := TFhirRequestGroupAction.create()
  else if name = 'RequestGroup.action.condition' then
    result := TFhirRequestGroupActionCondition.create()
  else if name = 'RequestGroup.action.relatedAction' then
    result := TFhirRequestGroupActionRelatedAction.create()
  else if name = 'RequestGroup' then
    result := TFhirRequestGroup.create()
{$ENDIF FHIR_REQUESTGROUP}
{$IFDEF FHIR_RESEARCHSTUDY}
  else if name = 'ResearchStudy.arm' then
    result := TFhirResearchStudyArm.create()
  else if name = 'ResearchStudy.objective' then
    result := TFhirResearchStudyObjective.create()
  else if name = 'ResearchStudy' then
    result := TFhirResearchStudy.create()
{$ENDIF FHIR_RESEARCHSTUDY}
{$IFDEF FHIR_RESEARCHSUBJECT}
  else if name = 'ResearchSubject' then
    result := TFhirResearchSubject.create()
{$ENDIF FHIR_RESEARCHSUBJECT}
{$IFDEF FHIR_RISKASSESSMENT}
  else if name = 'RiskAssessment.prediction' then
    result := TFhirRiskAssessmentPrediction.create()
  else if name = 'RiskAssessment' then
    result := TFhirRiskAssessment.create()
{$ENDIF FHIR_RISKASSESSMENT}
{$IFDEF FHIR_SCHEDULE}
  else if name = 'Schedule' then
    result := TFhirSchedule.create()
{$ENDIF FHIR_SCHEDULE}
{$IFDEF FHIR_SEARCHPARAMETER}
  else if name = 'SearchParameter.component' then
    result := TFhirSearchParameterComponent.create()
  else if name = 'SearchParameter' then
    result := TFhirSearchParameter.create()
{$ENDIF FHIR_SEARCHPARAMETER}
{$IFDEF FHIR_SEQUENCE}
  else if name = 'Sequence.referenceSeq' then
    result := TFhirSequenceReferenceSeq.create()
  else if name = 'Sequence.variant' then
    result := TFhirSequenceVariant.create()
  else if name = 'Sequence.quality' then
    result := TFhirSequenceQuality.create()
  else if name = 'Sequence.quality.roc' then
    result := TFhirSequenceQualityRoc.create()
  else if name = 'Sequence.repository' then
    result := TFhirSequenceRepository.create()
  else if name = 'Sequence.structureVariant' then
    result := TFhirSequenceStructureVariant.create()
  else if name = 'Sequence.structureVariant.outer' then
    result := TFhirSequenceStructureVariantOuter.create()
  else if name = 'Sequence.structureVariant.inner' then
    result := TFhirSequenceStructureVariantInner.create()
  else if name = 'Sequence' then
    result := TFhirSequence.create()
{$ENDIF FHIR_SEQUENCE}
{$IFDEF FHIR_SERVICEREQUEST}
  else if name = 'ServiceRequest' then
    result := TFhirServiceRequest.create()
{$ENDIF FHIR_SERVICEREQUEST}
{$IFDEF FHIR_SLOT}
  else if name = 'Slot' then
    result := TFhirSlot.create()
{$ENDIF FHIR_SLOT}
{$IFDEF FHIR_SPECIMEN}
  else if name = 'Specimen.collection' then
    result := TFhirSpecimenCollection.create()
  else if name = 'Specimen.processing' then
    result := TFhirSpecimenProcessing.create()
  else if name = 'Specimen.container' then
    result := TFhirSpecimenContainer.create()
  else if name = 'Specimen' then
    result := TFhirSpecimen.create()
{$ENDIF FHIR_SPECIMEN}
{$IFDEF FHIR_SPECIMENDEFINITION}
  else if name = 'SpecimenDefinition.specimenToLab' then
    result := TFhirSpecimenDefinitionSpecimenToLab.create()
  else if name = 'SpecimenDefinition.specimenToLab.containerAdditive' then
    result := TFhirSpecimenDefinitionSpecimenToLabContainerAdditive.create()
  else if name = 'SpecimenDefinition.specimenToLab.handling' then
    result := TFhirSpecimenDefinitionSpecimenToLabHandling.create()
  else if name = 'SpecimenDefinition' then
    result := TFhirSpecimenDefinition.create()
{$ENDIF FHIR_SPECIMENDEFINITION}
{$IFDEF FHIR_STRUCTUREDEFINITION}
  else if name = 'StructureDefinition.mapping' then
    result := TFhirStructureDefinitionMapping.create()
  else if name = 'StructureDefinition.context' then
    result := TFhirStructureDefinitionContext.create()
  else if name = 'StructureDefinition.snapshot' then
    result := TFhirStructureDefinitionSnapshot.create()
  else if name = 'StructureDefinition.differential' then
    result := TFhirStructureDefinitionDifferential.create()
  else if name = 'StructureDefinition' then
    result := TFhirStructureDefinition.create()
{$ENDIF FHIR_STRUCTUREDEFINITION}
{$IFDEF FHIR_STRUCTUREMAP}
  else if name = 'StructureMap.structure' then
    result := TFhirStructureMapStructure.create()
  else if name = 'StructureMap.group' then
    result := TFhirStructureMapGroup.create()
  else if name = 'StructureMap.group.input' then
    result := TFhirStructureMapGroupInput.create()
  else if name = 'StructureMap.group.rule' then
    result := TFhirStructureMapGroupRule.create()
  else if name = 'StructureMap.group.rule.source' then
    result := TFhirStructureMapGroupRuleSource.create()
  else if name = 'StructureMap.group.rule.target' then
    result := TFhirStructureMapGroupRuleTarget.create()
  else if name = 'StructureMap.group.rule.target.parameter' then
    result := TFhirStructureMapGroupRuleTargetParameter.create()
  else if name = 'StructureMap.group.rule.dependent' then
    result := TFhirStructureMapGroupRuleDependent.create()
  else if name = 'StructureMap' then
    result := TFhirStructureMap.create()
{$ENDIF FHIR_STRUCTUREMAP}
{$IFDEF FHIR_SUBSCRIPTION}
  else if name = 'Subscription.channel' then
    result := TFhirSubscriptionChannel.create()
  else if name = 'Subscription' then
    result := TFhirSubscription.create()
{$ENDIF FHIR_SUBSCRIPTION}
{$IFDEF FHIR_SUBSTANCE}
  else if name = 'Substance.instance' then
    result := TFhirSubstanceInstance.create()
  else if name = 'Substance.ingredient' then
    result := TFhirSubstanceIngredient.create()
  else if name = 'Substance' then
    result := TFhirSubstance.create()
{$ENDIF FHIR_SUBSTANCE}
{$IFDEF FHIR_SUBSTANCEPOLYMER}
  else if name = 'SubstancePolymer.monomerSet' then
    result := TFhirSubstancePolymerMonomerSet.create()
  else if name = 'SubstancePolymer.monomerSet.startingMaterial' then
    result := TFhirSubstancePolymerMonomerSetStartingMaterial.create()
  else if name = 'SubstancePolymer.repeat' then
    result := TFhirSubstancePolymerRepeat.create()
  else if name = 'SubstancePolymer.repeat.repeatUnit' then
    result := TFhirSubstancePolymerRepeatRepeatUnit.create()
  else if name = 'SubstancePolymer.repeat.repeatUnit.degreeOfPolymerisation' then
    result := TFhirSubstancePolymerRepeatRepeatUnitDegreeOfPolymerisation.create()
  else if name = 'SubstancePolymer.repeat.repeatUnit.structuralRepresentation' then
    result := TFhirSubstancePolymerRepeatRepeatUnitStructuralRepresentation.create()
  else if name = 'SubstancePolymer' then
    result := TFhirSubstancePolymer.create()
{$ENDIF FHIR_SUBSTANCEPOLYMER}
{$IFDEF FHIR_SUBSTANCEREFERENCEINFORMATION}
  else if name = 'SubstanceReferenceInformation.gene' then
    result := TFhirSubstanceReferenceInformationGene.create()
  else if name = 'SubstanceReferenceInformation.geneElement' then
    result := TFhirSubstanceReferenceInformationGeneElement.create()
  else if name = 'SubstanceReferenceInformation.classification' then
    result := TFhirSubstanceReferenceInformationClassification.create()
  else if name = 'SubstanceReferenceInformation.relationship' then
    result := TFhirSubstanceReferenceInformationRelationship.create()
  else if name = 'SubstanceReferenceInformation.target' then
    result := TFhirSubstanceReferenceInformationTarget.create()
  else if name = 'SubstanceReferenceInformation' then
    result := TFhirSubstanceReferenceInformation.create()
{$ENDIF FHIR_SUBSTANCEREFERENCEINFORMATION}
{$IFDEF FHIR_SUBSTANCESPECIFICATION}
  else if name = 'SubstanceSpecification.moiety' then
    result := TFhirSubstanceSpecificationMoiety.create()
  else if name = 'SubstanceSpecification.property' then
    result := TFhirSubstanceSpecificationProperty.create()
  else if name = 'SubstanceSpecification.structure' then
    result := TFhirSubstanceSpecificationStructure.create()
  else if name = 'SubstanceSpecification.structure.isotope' then
    result := TFhirSubstanceSpecificationStructureIsotope.create()
  else if name = 'SubstanceSpecification.structure.isotope.molecularWeight' then
    result := TFhirSubstanceSpecificationStructureIsotopeMolecularWeight.create()
  else if name = 'SubstanceSpecification.structure.structuralRepresentation' then
    result := TFhirSubstanceSpecificationStructureStructuralRepresentation.create()
  else if name = 'SubstanceSpecification.substanceCode' then
    result := TFhirSubstanceSpecificationSubstanceCode.create()
  else if name = 'SubstanceSpecification.substanceName' then
    result := TFhirSubstanceSpecificationSubstanceName.create()
  else if name = 'SubstanceSpecification.substanceName.officialName' then
    result := TFhirSubstanceSpecificationSubstanceNameOfficialName.create()
  else if name = 'SubstanceSpecification' then
    result := TFhirSubstanceSpecification.create()
{$ENDIF FHIR_SUBSTANCESPECIFICATION}
{$IFDEF FHIR_SUPPLYDELIVERY}
  else if name = 'SupplyDelivery.suppliedItem' then
    result := TFhirSupplyDeliverySuppliedItem.create()
  else if name = 'SupplyDelivery' then
    result := TFhirSupplyDelivery.create()
{$ENDIF FHIR_SUPPLYDELIVERY}
{$IFDEF FHIR_SUPPLYREQUEST}
  else if name = 'SupplyRequest.parameter' then
    result := TFhirSupplyRequestParameter.create()
  else if name = 'SupplyRequest' then
    result := TFhirSupplyRequest.create()
{$ENDIF FHIR_SUPPLYREQUEST}
{$IFDEF FHIR_TASK}
  else if name = 'Task.restriction' then
    result := TFhirTaskRestriction.create()
  else if name = 'Task.input' then
    result := TFhirTaskInput.create()
  else if name = 'Task.output' then
    result := TFhirTaskOutput.create()
  else if name = 'Task' then
    result := TFhirTask.create()
{$ENDIF FHIR_TASK}
{$IFDEF FHIR_TERMINOLOGYCAPABILITIES}
  else if name = 'TerminologyCapabilities.codeSystem' then
    result := TFhirTerminologyCapabilitiesCodeSystem.create()
  else if name = 'TerminologyCapabilities.codeSystem.version' then
    result := TFhirTerminologyCapabilitiesCodeSystemVersion.create()
  else if name = 'TerminologyCapabilities.codeSystem.version.filter' then
    result := TFhirTerminologyCapabilitiesCodeSystemVersionFilter.create()
  else if name = 'TerminologyCapabilities.expansion' then
    result := TFhirTerminologyCapabilitiesExpansion.create()
  else if name = 'TerminologyCapabilities.validateCode' then
    result := TFhirTerminologyCapabilitiesValidateCode.create()
  else if name = 'TerminologyCapabilities.translation' then
    result := TFhirTerminologyCapabilitiesTranslation.create()
  else if name = 'TerminologyCapabilities.closure' then
    result := TFhirTerminologyCapabilitiesClosure.create()
  else if name = 'TerminologyCapabilities' then
    result := TFhirTerminologyCapabilities.create()
{$ENDIF FHIR_TERMINOLOGYCAPABILITIES}
{$IFDEF FHIR_TESTREPORT}
  else if name = 'TestReport.participant' then
    result := TFhirTestReportParticipant.create()
  else if name = 'TestReport.setup' then
    result := TFhirTestReportSetup.create()
  else if name = 'TestReport.setup.action' then
    result := TFhirTestReportSetupAction.create()
  else if name = 'TestReport.setup.action.operation' then
    result := TFhirTestReportSetupActionOperation.create()
  else if name = 'TestReport.setup.action.assert' then
    result := TFhirTestReportSetupActionAssert.create()
  else if name = 'TestReport.test' then
    result := TFhirTestReportTest.create()
  else if name = 'TestReport.test.action' then
    result := TFhirTestReportTestAction.create()
  else if name = 'TestReport.teardown' then
    result := TFhirTestReportTeardown.create()
  else if name = 'TestReport.teardown.action' then
    result := TFhirTestReportTeardownAction.create()
  else if name = 'TestReport' then
    result := TFhirTestReport.create()
{$ENDIF FHIR_TESTREPORT}
{$IFDEF FHIR_TESTSCRIPT}
  else if name = 'TestScript.origin' then
    result := TFhirTestScriptOrigin.create()
  else if name = 'TestScript.destination' then
    result := TFhirTestScriptDestination.create()
  else if name = 'TestScript.metadata' then
    result := TFhirTestScriptMetadata.create()
  else if name = 'TestScript.metadata.link' then
    result := TFhirTestScriptMetadataLink.create()
  else if name = 'TestScript.metadata.capability' then
    result := TFhirTestScriptMetadataCapability.create()
  else if name = 'TestScript.fixture' then
    result := TFhirTestScriptFixture.create()
  else if name = 'TestScript.variable' then
    result := TFhirTestScriptVariable.create()
  else if name = 'TestScript.rule' then
    result := TFhirTestScriptRule.create()
  else if name = 'TestScript.rule.param' then
    result := TFhirTestScriptRuleParam.create()
  else if name = 'TestScript.ruleset' then
    result := TFhirTestScriptRuleset.create()
  else if name = 'TestScript.ruleset.rule' then
    result := TFhirTestScriptRulesetRule.create()
  else if name = 'TestScript.ruleset.rule.param' then
    result := TFhirTestScriptRulesetRuleParam.create()
  else if name = 'TestScript.setup' then
    result := TFhirTestScriptSetup.create()
  else if name = 'TestScript.setup.action' then
    result := TFhirTestScriptSetupAction.create()
  else if name = 'TestScript.setup.action.operation' then
    result := TFhirTestScriptSetupActionOperation.create()
  else if name = 'TestScript.setup.action.operation.requestHeader' then
    result := TFhirTestScriptSetupActionOperationRequestHeader.create()
  else if name = 'TestScript.setup.action.assert' then
    result := TFhirTestScriptSetupActionAssert.create()
  else if name = 'TestScript.setup.action.assert.rule' then
    result := TFhirTestScriptSetupActionAssertRule.create()
  else if name = 'TestScript.setup.action.assert.rule.param' then
    result := TFhirTestScriptSetupActionAssertRuleParam.create()
  else if name = 'TestScript.setup.action.assert.ruleset' then
    result := TFhirTestScriptSetupActionAssertRuleset.create()
  else if name = 'TestScript.setup.action.assert.ruleset.rule' then
    result := TFhirTestScriptSetupActionAssertRulesetRule.create()
  else if name = 'TestScript.setup.action.assert.ruleset.rule.param' then
    result := TFhirTestScriptSetupActionAssertRulesetRuleParam.create()
  else if name = 'TestScript.test' then
    result := TFhirTestScriptTest.create()
  else if name = 'TestScript.test.action' then
    result := TFhirTestScriptTestAction.create()
  else if name = 'TestScript.teardown' then
    result := TFhirTestScriptTeardown.create()
  else if name = 'TestScript.teardown.action' then
    result := TFhirTestScriptTeardownAction.create()
  else if name = 'TestScript' then
    result := TFhirTestScript.create()
{$ENDIF FHIR_TESTSCRIPT}
{$IFDEF FHIR_USERSESSION}
  else if name = 'UserSession.status' then
    result := TFhirUserSessionStatus.create()
  else if name = 'UserSession.context' then
    result := TFhirUserSessionContext.create()
  else if name = 'UserSession' then
    result := TFhirUserSession.create()
{$ENDIF FHIR_USERSESSION}
{$IFDEF FHIR_VALUESET}
  else if name = 'ValueSet.compose' then
    result := TFhirValueSetCompose.create()
  else if name = 'ValueSet.compose.include' then
    result := TFhirValueSetComposeInclude.create()
  else if name = 'ValueSet.compose.include.concept' then
    result := TFhirValueSetComposeIncludeConcept.create()
  else if name = 'ValueSet.compose.include.concept.designation' then
    result := TFhirValueSetComposeIncludeConceptDesignation.create()
  else if name = 'ValueSet.compose.include.filter' then
    result := TFhirValueSetComposeIncludeFilter.create()
  else if name = 'ValueSet.expansion' then
    result := TFhirValueSetExpansion.create()
  else if name = 'ValueSet.expansion.parameter' then
    result := TFhirValueSetExpansionParameter.create()
  else if name = 'ValueSet.expansion.contains' then
    result := TFhirValueSetExpansionContains.create()
  else if name = 'ValueSet' then
    result := TFhirValueSet.create()
{$ENDIF FHIR_VALUESET}
{$IFDEF FHIR_VERIFICATIONRESULT}
  else if name = 'VerificationResult.primarySource' then
    result := TFhirVerificationResultPrimarySource.create()
  else if name = 'VerificationResult.attestation' then
    result := TFhirVerificationResultAttestation.create()
  else if name = 'VerificationResult.validator' then
    result := TFhirVerificationResultValidator.create()
  else if name = 'VerificationResult' then
    result := TFhirVerificationResult.create()
{$ENDIF FHIR_VERIFICATIONRESULT}
{$IFDEF FHIR_VISIONPRESCRIPTION}
  else if name = 'VisionPrescription.dispense' then
    result := TFhirVisionPrescriptionDispense.create()
  else if name = 'VisionPrescription.dispense.prism' then
    result := TFhirVisionPrescriptionDispensePrism.create()
  else if name = 'VisionPrescription' then
    result := TFhirVisionPrescription.create()
{$ENDIF FHIR_VISIONPRESCRIPTION}

  else
    result := nil;
end;



end.

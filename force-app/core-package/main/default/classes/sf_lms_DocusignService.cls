/**
 * @author Martin Villanueva - Core Foundations Team
 * @date 09/29/2023
 * @description Docusign Service
 */

public with sharing class sf_lms_DocusignService implements IDocumentService {
    private static String accountId;
    private static String apiPath = sf_lms_IntegrationConstants.DOCUSIGN_API_PATH;
    private static String envelopeId = sf_lms_IntegrationConstants.DOCUSIGN_ENVELOPEID;
    private static String status = sf_lms_IntegrationConstants.DOCUSIGN_SENTSTATUS;
    private static String anchorString = sf_lms_IntegrationConstants.DOCUSIGN_ANCHORSTRING;
    private static String anchorUnits = sf_lms_IntegrationConstants.DOCUSIGN_ANCHORUNITS;
    private static String recipientId = sf_lms_IntegrationConstants.DOCUSIGN_RECIPIENTID;
    private static String anchorIgnoreIfNotPresent = sf_lms_IntegrationConstants.DOCUSIGN_ANCHORIGNOREIFNOTPRESENT;
    private static String textInputWidth = sf_lms_IntegrationConstants.DOCUSIGN_TEXT_INPUT_WIDTH;
    private static String vFPageName;
    private static String dsNamedCredential;
    private static String returnUrl;
    private static String clientUserId;
    private static String documentId;
    private static String userName = UserInfo.getName();
    private static String userEmail = UserInfo.getUserEmail();
    private static sf_lms_Docusign_Configuration__mdt dsConfiguration;
    private static String language;
    /**
     * @description Getter setter to retrieve coveo configuration and allows to mock for unit tests.
     */
    @TestVisible
    private static sf_lms_Docusign_Configuration__mdt config {
        get {
            if (config == null) {
                config = sf_lms_Docusign_Configuration__mdt.getInstance(
                    'DSConfig'
                );
            }
            return config;
        }
        set;
    }

    public sf_lms_DocusignService() {
        accountId = config.AccountId__c;
        vFPageName = config.VFPageName__c;
        dsNamedCredential = config.NamedCredential__c;
        returnUrl = config.ReturnUrl__c;
        clientUserId = config.Client_User_Id__c;
        documentId = config.Document_Id__c;
        language = UserInfo.getLanguage();
    }

    public Map<String, String> createEnvelopeAndEmbeddedURL() {
        String envId;
        String url;
        String base64PDFfile;
        try {
            if (System.Test.isRunningTest()) {
                String base64PDFfileResource = [
                        SELECT Id, Body
                        FROM StaticResource
                        WHERE Name = 'sf_lms_base64PDFfileSample'
                        LIMIT 1
                    ]
                    .body.toString();
                base64PDFfile = base64PDFfileResource;
            } else {
                Blob pdfData = new PageReference('/apex/' + vFPageName)
                    .getContent();
                base64PDFfile = EncodingUtil.base64Encode(pdfData);
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint(
                'callout:' +
                    dsNamedCredential +
                    apiPath +
                    accountId +
                    '/envelopes'
            );
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            req.setBody(
                buildEnvelopeCreationRequestBody(
                    base64PDFfile,
                    userEmail,
                    clientUserId,
                    userName
                )
            );
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if (res?.getBody() != null) {
                String responseBody = res.getBody();
                Map<String, Object> resultObject = (Map<String, Object>) JSON.deserializeUntyped(
                    responseBody
                );
                envId = (String) resultObject.get(envelopeId);
                url = createRecipient(envId);

                sf_lms_Util.saveLog(
                    '\n Docusign Response status code: ' +
                        res.getStatusCode() +
                        '\n\n Docusign Response body:' +
                        res.getBody(),
                    '\n\n\n Integration Request Payload : ' +
                    buildEnvelopeCreationRequestBody(
                        base64PDFfile,
                        userEmail,
                        clientUserId,
                        userName
                    ),
                    'DocuSign_CreateEnvelope',
                    LoggingLevel.INFO,
                    ''
                );
            }
        } catch (Exception ex) {
            sf_lms_Util.logException(
                ex,
                'Request Body : ' +
                buildEnvelopeCreationRequestBody(
                    base64PDFfile,
                    userEmail,
                    clientUserId,
                    userName
                ),
                'DocuSign_CreateEnvelope',
                ''
            );
        }
        return new Map<String, String>{
            'envelopeId' => envId,
            'embeddedURL' => url
        };
    }

    public String createRecipient(String envelopeId) {
        String url;
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(
                'callout:' +
                    dsNamedCredential +
                    apiPath +
                    accountId +
                    '/envelopes/' +
                    envelopeId +
                    '/views/recipient'
            );
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(
                buildUrlCreationRequestBody(
                    userEmail,
                    clientUserId,
                    returnUrl,
                    userName
                )
            );
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if (res?.getBody() != null) {
                String responseBody = res.getBody();
                Map<String, Object> resultObject = (Map<String, Object>) JSON.deserializeUntyped(
                    responseBody
                );
                url =
                    (String) resultObject.get('url') +
                    sf_lms_IntegrationConstants.DOCUSIGN_LOCALE +
                    language;

                sf_lms_Util.saveLog(
                    '\n Docusign Response status code: ' +
                        res.getStatusCode() +
                        '\n\n Docusign Response body:' +
                        res.getBody(),
                    '\n\n\n Integration Request Payload : ' +
                    buildUrlCreationRequestBody(
                        userEmail,
                        clientUserId,
                        returnUrl,
                        userName
                    ),
                    'DocuSign_CreateRecipient',
                    LoggingLevel.INFO,
                    ''
                );
            }
        } catch (Exception ex) {
            sf_lms_Util.logException(
                ex,
                'Request Body : ' +
                buildUrlCreationRequestBody(
                    userEmail,
                    clientUserId,
                    returnUrl,
                    userName
                ),
                'DocuSign_CreateRecipient',
                ''
            );
        }
        return url;
    }

    /**
     * @description Get Envelope is Signed or Not
     * @param docuSignAppId DocuSign Integration App Id
     * @param envelopeId DocuSign Envelope Id Sent to the User
     * @return True if Envelope is Signed otherwise False
     */
    public Boolean isEnvelopeSigned(String docuSignAppId, String envelopeId) {
        if (getEnvelopeStatus(docuSignAppId, envelopeId) == 'completed') {
            return true;
        }
        return false;
    }

    /**
     * @description Get Envelope Status Sent or Completed
     * @param docuSignAppId DocuSign Integration App Id
     * @param envelopeId DocuSign Envelope Id Sent to the User
     * @return current Status of Envelope
     */
    public String getEnvelopeStatus(String docuSignAppId, String envelopeId) {
        String statusValue = null;
        try {
            Http http = new Http();
            HttpRequest request = buildHttpRequest(
                dsNamedCredential,
                apiPath,
                accountId,
                envelopeId,
                ''
            );
            HttpResponse response = http.send(request);
            //log both success and failure responses.
            if (response != null) {
                sf_lms_Util.saveLog(
                    '\n Docusign Response status code: ' +
                        response.getStatusCode() +
                        '\n\n Docusign Response body:' +
                        response.getBody(),
                    '\n\n\n DocuSign App Id : ' +
                        docuSignAppId +
                        '\n EnvelopeId : ' +
                        envelopeId,
                    'DocuSign_EnvelopeStatus',
                    LoggingLevel.INFO,
                    ''
                );
            }
            if (
                response?.getStatusCode() ==
                sf_lms_IntegrationConstants.API_SUCCESS_CODE_200
            ) {
                String responseBody = response.getBody();
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
                    responseBody
                );
                //Getting the status attrbitue value from map
                statusValue = (String) responseMap.get('status');
            }
        } catch (Exception exc) {
            sf_lms_Util.logException(
                exc,
                '\n\n\n DocuSign App Id : ' +
                    docuSignAppId +
                    '\n EnvelopeId : ' +
                    envelopeId,
                'DocuSign_EnvelopeStatus',
                ''
            );
        }
        return statusValue;
    }

    /**
     * @description Get Envelope Status Sent or Completed
     * @param envelopeId DocuSign Envelope Id Sent to the User
     * @return Blob value of document
     */
    public Blob getEnvelopeSignedPDF(String envelopeId) {
        Blob documentBlob = null;
        try {
            Http http = new Http();
            HttpRequest request = buildHttpRequest(
                dsNamedCredential,
                apiPath,
                accountId,
                envelopeId,
                '/documents/combined'
            );
            HttpResponse response = http.send(request);
            if (response != null) {
                //log both success and failure responses.
                sf_lms_Util.saveLog(
                    '\n Docusign Response status code: ' +
                        response.getStatusCode() +
                        '\n\n Docusign Response body:' +
                        response.getBody(),
                    '\n\n\n Envelope Id : ' + envelopeId,
                    'DocuSign_GetEnvSignedPDF',
                    LoggingLevel.INFO,
                    ''
                );
            }
            if (
                response?.getStatusCode() ==
                sf_lms_IntegrationConstants.API_SUCCESS_CODE_200
            ) {
                //getting pdf doc as blob from response
                documentBlob = response.getBodyAsBlob();
            }
        } catch (Exception exc) {
            sf_lms_Util.logException(
                exc,
                'Envelope Id : ' + envelopeId,
                'DocuSign_GetEnvSignedPDF',
                ''
            );
        }
        return documentBlob;
    }

    /**
     * @description Get Envelope Status Sent or Completed
     * @param blobDocument Blob Value of Document
     * @param documentName Document Name
     * @param recordId Record Id Where This Document Will Be Attached
     * @param description
     * @return Boolean
     */
    public Attachment attachDocumentToRecord(
        Blob blobDocument,
        String documentName,
        String recordId,
        String description
    ) {
        Attachment att = null;
        if (
            blobDocument != null &&
            documentName != null &&
            String.isNotBlank(documentName) &&
            String.isNotBlank(recordId)
        ) {
            att = new Attachment();
            att.Body = blobDocument;
            att.Name = documentName;
            att.IsPrivate = false;
            att.ParentId = recordId;
            att.Description = description;
            insert att;
        }
        return att;
    }

    private static HttpRequest buildHttpRequest(
        String dsNamedCredential,
        String apiPath,
        String accountId,
        String envelopeId,
        String endPath
    ) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(
            'callout:' +
                dsNamedCredential +
                apiPath +
                accountId +
                '/envelopes/' +
                envelopeId +
                '/' +
                endPath
        );
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader(
            'Authorization',
            'Bearer {!$Credential.DocuSignExternal.Authorization}'
        );
        return request;
    }

    private static String buildEnvelopeCreationRequestBody(
        String base64PDFfile,
        String userEmail,
        String clientUserId,
        String userName
    ) {
        sf_lms_EnvelopeCreationRequestBody body = new sf_lms_EnvelopeCreationRequestBody();
        body.status = status;
        body.emailSubject = sf_lms_IntegrationConstants.DOCUSIGN_EMAILSUBJECT;
        body.allowComments = 'false';
        //documents
        List<sf_lms_EnvelopeDocument> documents = new List<sf_lms_EnvelopeDocument>();

        //signers
        List<sf_lms_EnvelopeSigners> signers = new List<sf_lms_EnvelopeSigners>();
        //sf_lms_EnvelopesignHereTabs
        sf_lms_EnvelopesignHereTabs signHereTab = new sf_lms_EnvelopesignHereTabs();
        signHereTab.documentId = documentId;
        signHereTab.anchorString = anchorString;
        signHereTab.anchorUnits = anchorUnits;
        signHereTab.anchorXOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_ANCHORXOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_ANCHORXOFFSET;
        signHereTab.anchorYOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_ANCHORYOFFSET
            : sf_lms_IntegrationConstants.DOCUSIGN_ANCHORYOFFSET;
        signHereTab.anchorIgnoreIfNotPresent = anchorIgnoreIfNotPresent;

        //checkbox tabs
        List<String> tabGroupLabels = new List<String>();
        tabGroupLabels.add('checkboxgroup1');

        sf_lms_CheckboxTab checkboxTabYes = new sf_lms_CheckboxTab();
        checkboxTabYes.tabLabel = sf_lms_IntegrationConstants.DOCUSIGN_CHECKBOX_YES;
        checkboxTabYes.anchorString =
            '] ' + sf_lms_IntegrationConstants.DOCUSIGN_CHECKBOX_YES;
        checkboxTabYes.anchorHorizontalAlignment = sf_lms_IntegrationConstants.DOCUSIGN_CHECKBOX_ALIGNMENT;
        checkboxTabYes.anchorYOffset = sf_lms_IntegrationConstants.DOCUSIGN_CHECKBOX_ANCHORYOFFSET;
        checkboxTabYes.anchorXOffset = sf_lms_IntegrationConstants.DOCUSIGN_CHECKBOX_ANCHORXOFFSET;
        checkboxTabYes.tabGroupLabels = tabGroupLabels;

        sf_lms_CheckboxTab checkboxTabNo = new sf_lms_CheckboxTab();
        checkboxTabNo.tabLabel = sf_lms_IntegrationConstants.DOCUSIGN_CHECKBOX_NO;
        checkboxTabNo.anchorString =
            '] ' + sf_lms_IntegrationConstants.DOCUSIGN_CHECKBOX_NO;
        checkboxTabNo.anchorHorizontalAlignment = sf_lms_IntegrationConstants.DOCUSIGN_CHECKBOX_ALIGNMENT;
        checkboxTabNo.anchorYOffset = sf_lms_IntegrationConstants.DOCUSIGN_CHECKBOX_ANCHORYOFFSET;
        checkboxTabNo.anchorXOffset = sf_lms_IntegrationConstants.DOCUSIGN_CHECKBOX_ANCHORXOFFSET;
        checkboxTabNo.tabGroupLabels = tabGroupLabels;

        sf_lms_tabGroup tabGroup = new sf_lms_tabGroup();
        tabGroup.groupLabel = tabGroupLabels[0];
        tabGroup.recipientId = recipientId;
        tabGroup.validationMessage = sf_lms_IntegrationConstants.DOCUSIGN_CHECK_A_BOX;
        tabGroup.groupRule = 'SelectAtMost';
        tabGroup.maximumAllowed = '1';
        tabGroup.documentId = documentId;
        tabGroup.pageNumber = '1';
        tabGroup.xPosition = '0';
        tabGroup.yPosition = '0';
        tabGroup.tabScope = 'Document';
        tabGroup.tabType = 'tabgroup';

        List<sf_lms_tabGroup> tabGroupsList = new List<sf_lms_tabGroup>();
        tabGroupsList.add(tabgroup);

        sf_lms_tabGroups tabGroups = new sf_lms_tabGroups();
        tabGroups.tabGroup = tabGroupsList;

        List<sf_lms_checkboxTab> checkboxTabsList = new List<sf_lms_checkboxTab>();
        checkboxTabsList.add(checkboxTabYes);
        checkboxTabsList.add(checkboxTabNo);

        sf_lms_checkboxTabs checkboxTabs = new sf_lms_checkboxTabs();
        checkboxTabs.checkboxTab = checkboxTabsList;

        //text tabs
        sf_lms_CustomTextTab poNumberTab = new sf_lms_CustomTextTab();
        poNumberTab.anchorString = sf_lms_IntegrationConstants.DOCUSIGN_PO_NUMBER;
        poNumberTab.anchorUnits = anchorUnits;
        poNumberTab.anchorXOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_PONUMBER_XOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_PONUMBER_XOFFSET;
        poNumberTab.anchorYOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_PONUMBER_YOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_PONUMBER_YOFFSET;
        poNumberTab.name = sf_lms_IntegrationConstants.DOCUSIGN_ENTER_PO_NUMBER;
        poNumberTab.documentId = documentId;
        poNumberTab.width = textInputWidth;
        poNumberTab.tabLabel = sf_lms_IntegrationConstants.DOCUSIGN_PO_NUMBER_LABEL;
        poNumberTab.required = 'false';

        sf_lms_CustomTextTab nameTab = new sf_lms_CustomTextTab();
        nameTab.anchorString = sf_lms_IntegrationConstants.DOCUSIGN_SIGNER_NAME;
        nameTab.anchorUnits = anchorUnits;
        nameTab.anchorXOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_SIGNER_XOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_SIGNER_XOFFSET;
        nameTab.anchorYOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_SIGNER_YOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_SIGNER_YOFFSET;
        nameTab.name = sf_lms_IntegrationConstants.DOCUSIGN_ENTER_NAME;
        nameTab.documentId = documentId;
        nameTab.width = textInputWidth;
        nameTab.tabLabel = sf_lms_IntegrationConstants.DOCUSIGN_SIGNER_LABEL;

        sf_lms_CustomTextTab businessTitleTab = new sf_lms_CustomTextTab();

        businessTitleTab.anchorString = sf_lms_IntegrationConstants.DOCUSIGN_BUSINESS_TITLE_ANCHORSTRING;
        businessTitleTab.anchorUnits = anchorUnits;
        businessTitleTab.anchorXOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_BUSINESS_TITLE_XOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_BUSINESS_TITLE_XOFFSET;
        businessTitleTab.anchorYOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_BUSINESS_TITLE_YOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_BUSINESS_TITLE_YOFFSET;
        businessTitleTab.name = sf_lms_IntegrationConstants.DOCUSIGN_ENTER_TITLE;
        businessTitleTab.documentId = documentId;
        businessTitleTab.width = textInputWidth;
        businessTitleTab.tabLabel = sf_lms_IntegrationConstants.DOCUSIGN_BUSINESS_TITLE_LABEL;

        sf_lms_CustomTextTab authorityLevelTab = new sf_lms_CustomTextTab();

        authorityLevelTab.anchorString = sf_lms_IntegrationConstants.DOCUSIGN_AUTHORITY_LEVEL_ANCHORSTRING;
        authorityLevelTab.anchorUnits = anchorUnits;
        authorityLevelTab.anchorXOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_AUTHORITY_LEVEL_XOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_AUTHORITY_LEVEL_XOFFSET;
        authorityLevelTab.anchorYOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_AUTHORITY_LEVEL_YOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_AUTHORITY_LEVEL_YOFFSET;
        authorityLevelTab.name = sf_lms_IntegrationConstants.DOCUSIGN_ENTER_AUTHORITY_LEVEL;
        authorityLevelTab.documentId = documentId;
        authorityLevelTab.width = textInputWidth;
        authorityLevelTab.tabLabel = sf_lms_IntegrationConstants.DOCUSIGN_AUTHORITY_LEVEL_LABEL;

        List<sf_lms_CustomTextTab> textTabs = new List<sf_lms_CustomTextTab>();
        textTabs.add(poNumberTab);
        textTabs.add(nameTab);
        textTabs.add(businessTitleTab);
        textTabs.add(authorityLevelTab);

        sf_lms_DocusignDateSignedTab dateSignedTab = new sf_lms_DocusignDateSignedTab();
        dateSignedTab.anchorString = sf_lms_IntegrationConstants.DOCUSIGN_BUSINESS_DATESIGNED_ANCHORSTRING;
        dateSignedTab.anchorUnits = anchorUnits;
        dateSignedTab.anchorXOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_SIGNEDDATE_XOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_SIGNEDDATE_XOFFSET;
        dateSignedTab.anchorYOffset = (language ==
            sf_lms_IntegrationConstants.JP_LANGUAGE)
            ? sf_lms_IntegrationConstants.DOCUSIGN_SIGNEDDATE_YOFFSET_JP
            : sf_lms_IntegrationConstants.DOCUSIGN_SIGNEDDATE_YOFFSET;
        dateSignedTab.name = 'Date';
        dateSignedTab.documentId = documentId;
        dateSignedTab.tabLabel = sf_lms_IntegrationConstants.DOCUSIGN_SIGNER_LABEL;
        List<sf_lms_DocusignDateSignedTab> dateSignedTabs = new List<sf_lms_DocusignDateSignedTab>();
        dateSignedTabs.add(dateSignedTab);

        sf_lms_CustomTextTabs customTextTab = new sf_lms_CustomTextTabs();
        customTextTab.textTab = textTabs;

        List<sf_lms_EnvelopesignHereTabs> signHereTabs = new List<sf_lms_EnvelopesignHereTabs>();
        signHereTabs.add(signHereTab);

        //sf_lms_EnvelopeSignersTabs
        sf_lms_EnvelopeSignersTabs tab = new sf_lms_EnvelopeSignersTabs();
        tab.signHereTabs = signHereTabs;
        tab.checkboxTabs = checkboxTabs.checkboxTab;
        tab.tabGroups = tabGroupsList;
        tab.textTabs = textTabs;
        tab.dateSignedTabs = dateSignedTabs;

        sf_lms_DocusignEmailNotification emailNotification = new sf_lms_DocusignEmailNotification();
        emailNotification.deliveryMethod = 'none';

        sf_lms_EnvelopeSigners signer = new sf_lms_EnvelopeSigners();
        signer.email = userEmail;
        signer.name = userName;
        signer.recipientId = recipientId;
        signer.clientUserId = clientUserId;
        signer.tabs = tab;
        signer.emailNotification = emailNotification;

        signers.add(signer);
        //recipients
        sf_lms_EnvelopeRecipients recipient = new sf_lms_EnvelopeRecipients();
        recipient.signers = signers;

        sf_lms_EnvelopeDocument doc = new sf_lms_EnvelopeDocument();
        doc.documentBase64 = base64PDFfile;
        doc.documentId = documentId;
        doc.name = sf_lms_IntegrationConstants.DOCUSIGN_DOCUMENTNAME;
        documents.add(doc);

        body.recipients = recipient;
        body.documents = documents;
        return JSON.serialize(body);
    }

    private static String buildUrlCreationRequestBody(
        String userEmail,
        String clientUserId,
        String returnUrl,
        String userName
    ) {
        sf_lms_UrlCreationRequestBody body = new sf_lms_UrlCreationRequestBody();
        body.authenticationMethod = sf_lms_IntegrationConstants.DOCUSIGN_AUTHENTICATIONMETHOD;
        body.email = userEmail;
        body.recipientId = recipientId;
        body.clientUserId = clientUserId;
        body.returnUrl = returnUrl;
        body.userName = userName;
        return JSON.serialize(body);
    }

    /**
     * @description Custom Exception Handling.
     */
    public class sf_lms_DocusignServiceException extends Exception {
    }
}

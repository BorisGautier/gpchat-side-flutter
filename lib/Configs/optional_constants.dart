const IsCallFeatureTotallyHide =
    false; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const Is24hrsTimeformat =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int GroupMemberslimit =
    500; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int BroadcastMemberslimit =
    500; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int StatusDeleteAfterInHours =
    24; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsLogoutButtonShowInSettingsPage =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const FeedbackEmail =
    'btchoukouaha@tbg.cm'; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingGroups =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingBroadcasts =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingStatus =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsPercentProgressShowWhileUploading =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxFileSizeAllowedInMB =
    100; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxNoOfFilesInMultiSharing =
    30; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxNoOfContactsSelectForForward =
    15; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.

//---- ####### Below Details Not neccsarily required unless you are using the Admin App:
const ConnectWithAdminApp =
    true; // If you are planning to use the admin app, set it to "true". We recommend it to always set it to true for Advance features whether you use the admin app or not.
const dynamic RateAppUrlAndroid =
    null; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const dynamic RateAppUrlIOS =
    null; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const TERMS_CONDITION_URL =
    'YOUR_TNC'; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const PRIVACY_POLICY_URL =
    'YOUR_PRIVACY_POLICY'; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
//--
const int ImageQualityCompress =
    50; // This is compress the chat image size in percent while uploading to firesbase storage
const int DpImageQualityCompress =
    25; // This is compress the user display picture  size in percent while uploading to firesbase storage

const bool IsVideoQualityCompress =
    true; // This is compress the video size  to medium qulaity while uploading to firesbase storage

int maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading =
    25; //Minimum Value should be 15.
int maxAdFailedLoadAttempts = 3; //Minimum Value should be 3.
const int timeOutSeconds = 60; // Default phone Auth Code auto retrival timeout
const IsShowNativeTimDate =
    true; // Show Date Time in the user selected langauge
const IsShowDeleteChatOption =
    false; // Show Delete Chat Button in the All Chats Screens.
const IsLazyLoadingChat = false; //## under development yet
const IsApplyBtoomNavBar = false; //## under development yet
const IsRemovePhoneNumberFromCallingPageWhenOnCall =
    false; //## under development yet

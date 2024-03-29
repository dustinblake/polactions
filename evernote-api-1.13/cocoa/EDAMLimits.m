/**
 * Autogenerated by Thrift
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 */

#import <Cocoa/Cocoa.h>

#import <TProtocol.h>
#import <TApplicationException.h>
#import <TProtocolUtil.h>


#import "EDAMLimits.h"

static int32_t EDAM_ATTRIBUTE_LEN_MIN = 1;
static int32_t EDAM_ATTRIBUTE_LEN_MAX = 4096;
static NSString * EDAM_ATTRIBUTE_REGEX = @"^[^\\p{Cc}\\p{Zl}\\p{Zp}]{1,4096}$";
static int32_t EDAM_ATTRIBUTE_LIST_MAX = 100;
static int32_t EDAM_GUID_LEN_MIN = 36;
static int32_t EDAM_GUID_LEN_MAX = 36;
static NSString * EDAM_GUID_REGEX = @"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";
static int32_t EDAM_EMAIL_LEN_MIN = 6;
static int32_t EDAM_EMAIL_LEN_MAX = 255;
static NSString * EDAM_EMAIL_LOCAL_REGEX = @"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*$";
static NSString * EDAM_EMAIL_DOMAIN_REGEX = @"^[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.([A-Za-z]{2,})$";
static NSString * EDAM_EMAIL_REGEX = @"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.([A-Za-z]{2,})$";
static int32_t EDAM_TIMEZONE_LEN_MIN = 1;
static int32_t EDAM_TIMEZONE_LEN_MAX = 32;
static NSString * EDAM_TIMEZONE_REGEX = @"^([A-Za-z_-]+(/[A-Za-z_-]+)*)|(GMT(-|\\+)[0-9]{1,2}(:[0-9]{2})?)$";
static int32_t EDAM_MIME_LEN_MIN = 3;
static int32_t EDAM_MIME_LEN_MAX = 50;
static NSString * EDAM_MIME_REGEX = @"^[A-Za-z]+/[A-Za-z0-9._+-]+$";
static NSString * EDAM_MIME_TYPE_GIF = @"image/gif";
static NSString * EDAM_MIME_TYPE_JPEG = @"image/jpeg";
static NSString * EDAM_MIME_TYPE_PNG = @"image/png";
static NSString * EDAM_MIME_TYPE_WAV = @"audio/wav";
static NSString * EDAM_MIME_TYPE_MP3 = @"audio/mpeg";
static NSString * EDAM_MIME_TYPE_AMR = @"audio/amr";
static NSString * EDAM_MIME_TYPE_INK = @"application/vnd.evernote.ink";
static NSString * EDAM_MIME_TYPE_PDF = @"application/pdf";
static NSString * EDAM_MIME_TYPE_DEFAULT = @"application/octet-stream";
static NSSet * EDAM_MIME_TYPES;
static NSString * EDAM_COMMERCE_SERVICE_GOOGLE = @"Google";
static NSString * EDAM_COMMERCE_SERVICE_PAYPAL = @"Paypal";
static NSString * EDAM_COMMERCE_SERVICE_GIFT = @"Gift";
static NSString * EDAM_COMMERCE_SERVICE_TRIALPAY = @"TrialPay";
static int32_t EDAM_SEARCH_QUERY_LEN_MIN = 0;
static int32_t EDAM_SEARCH_QUERY_LEN_MAX = 1024;
static NSString * EDAM_SEARCH_QUERY_REGEX = @"^[^\\p{Cc}\\p{Zl}\\p{Zp}]{0,1024}$";
static int32_t EDAM_HASH_LEN = 16;
static int32_t EDAM_USER_USERNAME_LEN_MIN = 1;
static int32_t EDAM_USER_USERNAME_LEN_MAX = 64;
static NSString * EDAM_USER_USERNAME_REGEX = @"^[a-z0-9]([a-z0-9_-]{0,62}[a-z0-9])?$";
static int32_t EDAM_USER_NAME_LEN_MIN = 1;
static int32_t EDAM_USER_NAME_LEN_MAX = 255;
static NSString * EDAM_USER_NAME_REGEX = @"^[^\\p{Cc}\\p{Zl}\\p{Zp}]{1,255}$";
static int32_t EDAM_TAG_NAME_LEN_MIN = 1;
static int32_t EDAM_TAG_NAME_LEN_MAX = 100;
static NSString * EDAM_TAG_NAME_REGEX = @"^[^,\\p{Cc}\\p{Z}]([^,\\p{Cc}\\p{Zl}\\p{Zp}]{0,98}[^,\\p{Cc}\\p{Z}])?$";
static int32_t EDAM_NOTE_TITLE_LEN_MIN = 1;
static int32_t EDAM_NOTE_TITLE_LEN_MAX = 255;
static NSString * EDAM_NOTE_TITLE_REGEX = @"^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,253}[^\\p{Cc}\\p{Z}])?$";
static int32_t EDAM_NOTE_CONTENT_LEN_MIN = 0;
static int32_t EDAM_NOTE_CONTENT_LEN_MAX = 5242880;
static int32_t EDAM_NOTEBOOK_NAME_LEN_MIN = 1;
static int32_t EDAM_NOTEBOOK_NAME_LEN_MAX = 100;
static NSString * EDAM_NOTEBOOK_NAME_REGEX = @"^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,98}[^\\p{Cc}\\p{Z}])?$";
static int32_t EDAM_PUBLISHING_URI_LEN_MIN = 1;
static int32_t EDAM_PUBLISHING_URI_LEN_MAX = 255;
static NSString * EDAM_PUBLISHING_URI_REGEX = @"^[a-zA-Z0-9.~_+-]{1,255}$";
static NSSet * EDAM_PUBLISHING_URI_PROHIBITED;
static int32_t EDAM_PUBLISHING_DESCRIPTION_LEN_MIN = 1;
static int32_t EDAM_PUBLISHING_DESCRIPTION_LEN_MAX = 200;
static NSString * EDAM_PUBLISHING_DESCRIPTION_REGEX = @"^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,198}[^\\p{Cc}\\p{Z}])?$";
static int32_t EDAM_SAVED_SEARCH_NAME_LEN_MIN = 1;
static int32_t EDAM_SAVED_SEARCH_NAME_LEN_MAX = 100;
static NSString * EDAM_SAVED_SEARCH_NAME_REGEX = @"^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,98}[^\\p{Cc}\\p{Z}])?$";
static int32_t EDAM_USER_PASSWORD_LEN_MIN = 6;
static int32_t EDAM_USER_PASSWORD_LEN_MAX = 64;
static NSString * EDAM_USER_PASSWORD_REGEX = @"^[A-Za-z0-9!#$%&'()*+,./:;<=>?@^_`{|}~\\[\\]\\\\-]{6,64}$";
static int32_t EDAM_NOTE_TAGS_MAX = 100;
static int32_t EDAM_NOTE_RESOURCES_MAX = 1000;
static int32_t EDAM_USER_TAGS_MAX = 100000;
static int32_t EDAM_USER_SAVED_SEARCHES_MAX = 100;
static int32_t EDAM_USER_NOTES_MAX = 100000;
static int32_t EDAM_USER_NOTEBOOKS_MAX = 100;
static int32_t EDAM_USER_RECENT_MAILED_ADDRESSES_MAX = 10;
static int32_t EDAM_USER_MAIL_LIMIT_DAILY_FREE = 50;
static int32_t EDAM_USER_MAIL_LIMIT_DAILY_PREMIUM = 200;
static int32_t EDAM_NOTE_SIZE_MAX_FREE = 26214400;
static int32_t EDAM_NOTE_SIZE_MAX_PREMIUM = 52428800;
static int32_t EDAM_RESOURCE_SIZE_MAX_FREE = 26214400;
static int32_t EDAM_RESOURCE_SIZE_MAX_PREMIUM = 52428800;
static int32_t EDAM_USER_LINKED_NOTEBOOK_MAX = 100;
static int32_t EDAM_NOTEBOOK_SHARED_NOTEBOOK_MAX = 100;

@implementation EDAMLimitsConstants
+ (void) initialize {
  EDAM_MIME_TYPES = [[NSSet alloc] initWithObjects: @"image/gif", @"image/jpeg", @"image/png", @"audio/wav", @"audio/mpeg", @"audio/amr", @"application/vnd.evernote.ink", @"application/pdf", nil];
  EDAM_PUBLISHING_URI_PROHIBITED = [[NSSet alloc] initWithObjects: @"..", nil];
}
+ (int32_t) EDAM_ATTRIBUTE_LEN_MIN{
  return EDAM_ATTRIBUTE_LEN_MIN;
}
+ (int32_t) EDAM_ATTRIBUTE_LEN_MAX{
  return EDAM_ATTRIBUTE_LEN_MAX;
}
+ (NSString *) EDAM_ATTRIBUTE_REGEX{
  return EDAM_ATTRIBUTE_REGEX;
}
+ (int32_t) EDAM_ATTRIBUTE_LIST_MAX{
  return EDAM_ATTRIBUTE_LIST_MAX;
}
+ (int32_t) EDAM_GUID_LEN_MIN{
  return EDAM_GUID_LEN_MIN;
}
+ (int32_t) EDAM_GUID_LEN_MAX{
  return EDAM_GUID_LEN_MAX;
}
+ (NSString *) EDAM_GUID_REGEX{
  return EDAM_GUID_REGEX;
}
+ (int32_t) EDAM_EMAIL_LEN_MIN{
  return EDAM_EMAIL_LEN_MIN;
}
+ (int32_t) EDAM_EMAIL_LEN_MAX{
  return EDAM_EMAIL_LEN_MAX;
}
+ (NSString *) EDAM_EMAIL_LOCAL_REGEX{
  return EDAM_EMAIL_LOCAL_REGEX;
}
+ (NSString *) EDAM_EMAIL_DOMAIN_REGEX{
  return EDAM_EMAIL_DOMAIN_REGEX;
}
+ (NSString *) EDAM_EMAIL_REGEX{
  return EDAM_EMAIL_REGEX;
}
+ (int32_t) EDAM_TIMEZONE_LEN_MIN{
  return EDAM_TIMEZONE_LEN_MIN;
}
+ (int32_t) EDAM_TIMEZONE_LEN_MAX{
  return EDAM_TIMEZONE_LEN_MAX;
}
+ (NSString *) EDAM_TIMEZONE_REGEX{
  return EDAM_TIMEZONE_REGEX;
}
+ (int32_t) EDAM_MIME_LEN_MIN{
  return EDAM_MIME_LEN_MIN;
}
+ (int32_t) EDAM_MIME_LEN_MAX{
  return EDAM_MIME_LEN_MAX;
}
+ (NSString *) EDAM_MIME_REGEX{
  return EDAM_MIME_REGEX;
}
+ (NSString *) EDAM_MIME_TYPE_GIF{
  return EDAM_MIME_TYPE_GIF;
}
+ (NSString *) EDAM_MIME_TYPE_JPEG{
  return EDAM_MIME_TYPE_JPEG;
}
+ (NSString *) EDAM_MIME_TYPE_PNG{
  return EDAM_MIME_TYPE_PNG;
}
+ (NSString *) EDAM_MIME_TYPE_WAV{
  return EDAM_MIME_TYPE_WAV;
}
+ (NSString *) EDAM_MIME_TYPE_MP3{
  return EDAM_MIME_TYPE_MP3;
}
+ (NSString *) EDAM_MIME_TYPE_AMR{
  return EDAM_MIME_TYPE_AMR;
}
+ (NSString *) EDAM_MIME_TYPE_INK{
  return EDAM_MIME_TYPE_INK;
}
+ (NSString *) EDAM_MIME_TYPE_PDF{
  return EDAM_MIME_TYPE_PDF;
}
+ (NSString *) EDAM_MIME_TYPE_DEFAULT{
  return EDAM_MIME_TYPE_DEFAULT;
}
+ (NSSet *) EDAM_MIME_TYPES{
  return EDAM_MIME_TYPES;
}
+ (NSString *) EDAM_COMMERCE_SERVICE_GOOGLE{
  return EDAM_COMMERCE_SERVICE_GOOGLE;
}
+ (NSString *) EDAM_COMMERCE_SERVICE_PAYPAL{
  return EDAM_COMMERCE_SERVICE_PAYPAL;
}
+ (NSString *) EDAM_COMMERCE_SERVICE_GIFT{
  return EDAM_COMMERCE_SERVICE_GIFT;
}
+ (NSString *) EDAM_COMMERCE_SERVICE_TRIALPAY{
  return EDAM_COMMERCE_SERVICE_TRIALPAY;
}
+ (int32_t) EDAM_SEARCH_QUERY_LEN_MIN{
  return EDAM_SEARCH_QUERY_LEN_MIN;
}
+ (int32_t) EDAM_SEARCH_QUERY_LEN_MAX{
  return EDAM_SEARCH_QUERY_LEN_MAX;
}
+ (NSString *) EDAM_SEARCH_QUERY_REGEX{
  return EDAM_SEARCH_QUERY_REGEX;
}
+ (int32_t) EDAM_HASH_LEN{
  return EDAM_HASH_LEN;
}
+ (int32_t) EDAM_USER_USERNAME_LEN_MIN{
  return EDAM_USER_USERNAME_LEN_MIN;
}
+ (int32_t) EDAM_USER_USERNAME_LEN_MAX{
  return EDAM_USER_USERNAME_LEN_MAX;
}
+ (NSString *) EDAM_USER_USERNAME_REGEX{
  return EDAM_USER_USERNAME_REGEX;
}
+ (int32_t) EDAM_USER_NAME_LEN_MIN{
  return EDAM_USER_NAME_LEN_MIN;
}
+ (int32_t) EDAM_USER_NAME_LEN_MAX{
  return EDAM_USER_NAME_LEN_MAX;
}
+ (NSString *) EDAM_USER_NAME_REGEX{
  return EDAM_USER_NAME_REGEX;
}
+ (int32_t) EDAM_TAG_NAME_LEN_MIN{
  return EDAM_TAG_NAME_LEN_MIN;
}
+ (int32_t) EDAM_TAG_NAME_LEN_MAX{
  return EDAM_TAG_NAME_LEN_MAX;
}
+ (NSString *) EDAM_TAG_NAME_REGEX{
  return EDAM_TAG_NAME_REGEX;
}
+ (int32_t) EDAM_NOTE_TITLE_LEN_MIN{
  return EDAM_NOTE_TITLE_LEN_MIN;
}
+ (int32_t) EDAM_NOTE_TITLE_LEN_MAX{
  return EDAM_NOTE_TITLE_LEN_MAX;
}
+ (NSString *) EDAM_NOTE_TITLE_REGEX{
  return EDAM_NOTE_TITLE_REGEX;
}
+ (int32_t) EDAM_NOTE_CONTENT_LEN_MIN{
  return EDAM_NOTE_CONTENT_LEN_MIN;
}
+ (int32_t) EDAM_NOTE_CONTENT_LEN_MAX{
  return EDAM_NOTE_CONTENT_LEN_MAX;
}
+ (int32_t) EDAM_NOTEBOOK_NAME_LEN_MIN{
  return EDAM_NOTEBOOK_NAME_LEN_MIN;
}
+ (int32_t) EDAM_NOTEBOOK_NAME_LEN_MAX{
  return EDAM_NOTEBOOK_NAME_LEN_MAX;
}
+ (NSString *) EDAM_NOTEBOOK_NAME_REGEX{
  return EDAM_NOTEBOOK_NAME_REGEX;
}
+ (int32_t) EDAM_PUBLISHING_URI_LEN_MIN{
  return EDAM_PUBLISHING_URI_LEN_MIN;
}
+ (int32_t) EDAM_PUBLISHING_URI_LEN_MAX{
  return EDAM_PUBLISHING_URI_LEN_MAX;
}
+ (NSString *) EDAM_PUBLISHING_URI_REGEX{
  return EDAM_PUBLISHING_URI_REGEX;
}
+ (NSSet *) EDAM_PUBLISHING_URI_PROHIBITED{
  return EDAM_PUBLISHING_URI_PROHIBITED;
}
+ (int32_t) EDAM_PUBLISHING_DESCRIPTION_LEN_MIN{
  return EDAM_PUBLISHING_DESCRIPTION_LEN_MIN;
}
+ (int32_t) EDAM_PUBLISHING_DESCRIPTION_LEN_MAX{
  return EDAM_PUBLISHING_DESCRIPTION_LEN_MAX;
}
+ (NSString *) EDAM_PUBLISHING_DESCRIPTION_REGEX{
  return EDAM_PUBLISHING_DESCRIPTION_REGEX;
}
+ (int32_t) EDAM_SAVED_SEARCH_NAME_LEN_MIN{
  return EDAM_SAVED_SEARCH_NAME_LEN_MIN;
}
+ (int32_t) EDAM_SAVED_SEARCH_NAME_LEN_MAX{
  return EDAM_SAVED_SEARCH_NAME_LEN_MAX;
}
+ (NSString *) EDAM_SAVED_SEARCH_NAME_REGEX{
  return EDAM_SAVED_SEARCH_NAME_REGEX;
}
+ (int32_t) EDAM_USER_PASSWORD_LEN_MIN{
  return EDAM_USER_PASSWORD_LEN_MIN;
}
+ (int32_t) EDAM_USER_PASSWORD_LEN_MAX{
  return EDAM_USER_PASSWORD_LEN_MAX;
}
+ (NSString *) EDAM_USER_PASSWORD_REGEX{
  return EDAM_USER_PASSWORD_REGEX;
}
+ (int32_t) EDAM_NOTE_TAGS_MAX{
  return EDAM_NOTE_TAGS_MAX;
}
+ (int32_t) EDAM_NOTE_RESOURCES_MAX{
  return EDAM_NOTE_RESOURCES_MAX;
}
+ (int32_t) EDAM_USER_TAGS_MAX{
  return EDAM_USER_TAGS_MAX;
}
+ (int32_t) EDAM_USER_SAVED_SEARCHES_MAX{
  return EDAM_USER_SAVED_SEARCHES_MAX;
}
+ (int32_t) EDAM_USER_NOTES_MAX{
  return EDAM_USER_NOTES_MAX;
}
+ (int32_t) EDAM_USER_NOTEBOOKS_MAX{
  return EDAM_USER_NOTEBOOKS_MAX;
}
+ (int32_t) EDAM_USER_RECENT_MAILED_ADDRESSES_MAX{
  return EDAM_USER_RECENT_MAILED_ADDRESSES_MAX;
}
+ (int32_t) EDAM_USER_MAIL_LIMIT_DAILY_FREE{
  return EDAM_USER_MAIL_LIMIT_DAILY_FREE;
}
+ (int32_t) EDAM_USER_MAIL_LIMIT_DAILY_PREMIUM{
  return EDAM_USER_MAIL_LIMIT_DAILY_PREMIUM;
}
+ (int32_t) EDAM_NOTE_SIZE_MAX_FREE{
  return EDAM_NOTE_SIZE_MAX_FREE;
}
+ (int32_t) EDAM_NOTE_SIZE_MAX_PREMIUM{
  return EDAM_NOTE_SIZE_MAX_PREMIUM;
}
+ (int32_t) EDAM_RESOURCE_SIZE_MAX_FREE{
  return EDAM_RESOURCE_SIZE_MAX_FREE;
}
+ (int32_t) EDAM_RESOURCE_SIZE_MAX_PREMIUM{
  return EDAM_RESOURCE_SIZE_MAX_PREMIUM;
}
+ (int32_t) EDAM_USER_LINKED_NOTEBOOK_MAX{
  return EDAM_USER_LINKED_NOTEBOOK_MAX;
}
+ (int32_t) EDAM_NOTEBOOK_SHARED_NOTEBOOK_MAX{
  return EDAM_NOTEBOOK_SHARED_NOTEBOOK_MAX;
}
@end


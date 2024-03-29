/*
 * Copyright (c) 2007-2008 by EverNote Corporation, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.    
 */

/*
 * This file contains the allowable limits for the various fields and 
 * collections that make up the EDAM data model.
 */

namespace java com.evernote.edam.limits
namespace csharp Evernote.EDAM.Limits
namespace py evernote.edam.limits
namespace cpp evernote.limits
namespace rb Evernote.EDAM.Limits
namespace php edam_limits
namespace cocoa EDAM
namespace perl EDAMLimits


// ========================== string field limits ==============================

/**
 * Minimum length of any string-based attribute, in Unicode chars
 */
const i32    EDAM_ATTRIBUTE_LEN_MIN = 1;
/**
 * Maximum length of any string-based attribute, in Unicode chars
 */
const i32    EDAM_ATTRIBUTE_LEN_MAX = 4096;
/**
 * Any string-based attribute must match the provided regular expression.
 * This excludes all Unicode line endings and control characters.
 */
const string EDAM_ATTRIBUTE_REGEX = "^[^\\p{Cc}\\p{Zl}\\p{Zp}]{1,4096}$";

/**
 * The maximum number of values that can be stored in a list-based attribute
 * (e.g. see UserAttributes.recentMailedAddresses)
 */
const i32    EDAM_ATTRIBUTE_LIST_MAX = 100;

/**
 * The minimum length of a GUID generated by the Evernote service
 */
const i32    EDAM_GUID_LEN_MIN = 36;
/**
 * The maximum length of a GUID generated by the Evernote service
 */
const i32    EDAM_GUID_LEN_MAX = 36;
/**
 * GUIDs generated by the Evernote service will match the provided pattern
 */
const string EDAM_GUID_REGEX = 
  "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";

/**
 * The minimum length of any email address
 */
const i32    EDAM_EMAIL_LEN_MIN = 6;
/**
 * The maximum length of any email address
 */
const i32    EDAM_EMAIL_LEN_MAX = 255;
/**
 * A regular expression that matches the part of an email address before
 * the '@' symbol.
 */
const string EDAM_EMAIL_LOCAL_REGEX =
  "^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*$";
/**
 * A regular expression that matches the part of an email address after
 * the '@' symbol.
 */
const string EDAM_EMAIL_DOMAIN_REGEX =
  "^[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.([A-Za-z]{2,})$";
/**
 * A regular expression that must match any email address given to Evernote.
 * Email addresses must comply with RFC 2821 and 2822.
 */
const string EDAM_EMAIL_REGEX = 
  "^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.([A-Za-z]{2,})$";

/**
 * The minimum length of a timezone specification string
 */
const i32    EDAM_TIMEZONE_LEN_MIN = 1;
/**
 * The maximum length of a timezone specification string
 */
const i32    EDAM_TIMEZONE_LEN_MAX = 32;
/**
 * Any timezone string given to Evernote must match the provided pattern.
 * This permits either a locale-based standard timezone or a GMT offset.
 * E.g.:<ul>
 *    <li>America/Los_Angeles</li>
 *    <li>GMT+08:00</li>
 * </ul>
 */
const string EDAM_TIMEZONE_REGEX = 
  "^([A-Za-z_-]+(/[A-Za-z_-]+)*)|(GMT(-|\\+)[0-9]{1,2}(:[0-9]{2})?)$";

/**
 * The minimum length of any MIME type string given to Evernote
 */
const i32    EDAM_MIME_LEN_MIN = 3;
/**
 * The maximum length of any MIME type string given to Evernote
 */
const i32    EDAM_MIME_LEN_MAX = 50;
/**
 * Any MIME type string given to Evernote must match the provided pattern.
 * E.g.:  image/gif
 */
const string EDAM_MIME_REGEX = "^[A-Za-z]+/[A-Za-z0-9._+-]+$";

/** Canonical MIME type string for GIF image resources */
const string EDAM_MIME_TYPE_GIF = "image/gif";
/** Canonical MIME type string for JPEG image resources */
const string EDAM_MIME_TYPE_JPEG = "image/jpeg";
/** Canonical MIME type string for PNG image resources */
const string EDAM_MIME_TYPE_PNG = "image/png";
/** Canonical MIME type string for WAV audio resources */
const string EDAM_MIME_TYPE_WAV = "audio/wav";
/** Canonical MIME type string for MP3 audio resources */
const string EDAM_MIME_TYPE_MP3 = "audio/mpeg";
/** Canonical MIME type string for AMR audio resources */
const string EDAM_MIME_TYPE_AMR = "audio/amr";
/** Canonical MIME type string for Evernote Ink resources */
const string EDAM_MIME_TYPE_INK = "application/vnd.evernote.ink";
/** Canonical MIME type string for PDF resources */
const string EDAM_MIME_TYPE_PDF = "application/pdf";
/** MIME type used for file attachments for Premium accounts */
const string EDAM_MIME_TYPE_DEFAULT = "application/octet-stream";

/**
 * The set of allowable resource MIME types for Resources that may be stored
 * within the notes of any Evernote user (Free or Premium).
 * Resources using other MIME types are not supported for Free accounts.
 */
const set<string> EDAM_MIME_TYPES = [
  EDAM_MIME_TYPE_GIF,
  EDAM_MIME_TYPE_JPEG,
  EDAM_MIME_TYPE_PNG,
  EDAM_MIME_TYPE_WAV,
  EDAM_MIME_TYPE_MP3,
  EDAM_MIME_TYPE_AMR,
  EDAM_MIME_TYPE_INK,
  EDAM_MIME_TYPE_PDF
];

/**
 * Commerce Services used
 */
const string EDAM_COMMERCE_SERVICE_GOOGLE = "Google";
const string EDAM_COMMERCE_SERVICE_PAYPAL = "Paypal";
const string EDAM_COMMERCE_SERVICE_GIFT   = "Gift";
const string EDAM_COMMERCE_SERVICE_TRIALPAY   = "TrialPay";

/**
 * The minimum length of a user search query string in Unicode chars
 */
const i32    EDAM_SEARCH_QUERY_LEN_MIN = 0;
/**
 * The maximum length of a user search query string in Unicode chars
 */
const i32    EDAM_SEARCH_QUERY_LEN_MAX = 1024;
/**
 * Search queries must match the provided pattern.  This is used for
 * both ad-hoc queries and SavedSearch.query fields.
 * This excludes all control characters and line/paragraph separators.
 */
const string EDAM_SEARCH_QUERY_REGEX = "^[^\\p{Cc}\\p{Zl}\\p{Zp}]{0,1024}$";

/**
 * The exact length of a MD5 hash checksum, in binary bytes.
 * This is the exact length that must be matched for any binary hash
 * value.
 */
const i32    EDAM_HASH_LEN = 16;

/**
 * The minimum length of an Evernote username
 */
const i32    EDAM_USER_USERNAME_LEN_MIN = 1;
/**
 * The maximum length of an Evernote username
 */
const i32    EDAM_USER_USERNAME_LEN_MAX = 64;
/**
 * Any Evernote User.username field must match this pattern.  This
 * restricts usernames to a format that could permit use as a domain
 * name component.  E.g. "username.whatever.evernote.com"
 */
const string EDAM_USER_USERNAME_REGEX = "^[a-z0-9]([a-z0-9_-]{0,62}[a-z0-9])?$";

/**
 * Minimum length of the User.name field
 */
const i32    EDAM_USER_NAME_LEN_MIN = 1;
/**
 * Maximum length of the User.name field
 */
const i32    EDAM_USER_NAME_LEN_MAX = 255;
/**
 * The User.name field must match this pattern, which excludes line
 * endings and control characters.
 */
const string EDAM_USER_NAME_REGEX = "^[^\\p{Cc}\\p{Zl}\\p{Zp}]{1,255}$";

/**
 * The minimum length of a Tag.name, in Unicode characters
 */
const i32    EDAM_TAG_NAME_LEN_MIN = 1;
/**
 * The maximum length of a Tag.name, in Unicode characters
 */
const i32    EDAM_TAG_NAME_LEN_MAX = 100;
/**
 * All Tag.name fields must match this pattern.
 * This excludes control chars, commas or line/paragraph separators.
 * The string may not begin or end with whitespace.
 */
const string EDAM_TAG_NAME_REGEX = 
  "^[^,\\p{Cc}\\p{Z}]([^,\\p{Cc}\\p{Zl}\\p{Zp}]{0,98}[^,\\p{Cc}\\p{Z}])?$";
	
/**
 * The minimum length of a Note.title, in Unicode characters
 */
const i32    EDAM_NOTE_TITLE_LEN_MIN = 1;
/**
 * The maximum length of a Note.title, in Unicode characters
 */
const i32    EDAM_NOTE_TITLE_LEN_MAX = 255;
/**
 * All Note.title fields must match this pattern.
 * This excludes control chars or line/paragraph separators.
 * The string may not begin or end with whitespace.
 */
const string EDAM_NOTE_TITLE_REGEX = 
  "^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,253}[^\\p{Cc}\\p{Z}])?$";

/**
 * Minimum length of a Note.content field.
 * Note.content fields must comply with the ENML DTD.
 */
const i32    EDAM_NOTE_CONTENT_LEN_MIN = 0;
/**
 * Maximum length of a Note.content field
 * Note.content fields must comply with the ENML DTD.
 */
const i32    EDAM_NOTE_CONTENT_LEN_MAX = 5242880;

/**
 * The minimum length of a Notebook.name, in Unicode characters
 */
const i32    EDAM_NOTEBOOK_NAME_LEN_MIN = 1;
/**
 * The maximum length of a Notebook.name, in Unicode characters
 */
const i32    EDAM_NOTEBOOK_NAME_LEN_MAX = 100;
/**
 * All Notebook.name fields must match this pattern.
 * This excludes control chars or line/paragraph separators.
 * The string may not begin or end with whitespace.
 */
const string EDAM_NOTEBOOK_NAME_REGEX =
  "^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,98}[^\\p{Cc}\\p{Z}])?$";

/**
 * The minimum length of a public notebook URI component
 */
const i32    EDAM_PUBLISHING_URI_LEN_MIN = 1;
/**
 * The maximum length of a public notebook URI component
 */
const i32    EDAM_PUBLISHING_URI_LEN_MAX = 255;
/**
 * A public notebook URI component must match the provided pattern
 */
const string EDAM_PUBLISHING_URI_REGEX = "^[a-zA-Z0-9.~_+-]{1,255}$";
/**
 * The set of strings that may not be used as a publishing URI
 */
const set<string> EDAM_PUBLISHING_URI_PROHIBITED = [ ".." ];

/**
 * The minimum length of a Publishing.publicDescription field.
 */
const i32    EDAM_PUBLISHING_DESCRIPTION_LEN_MIN = 1;
/**
 * The maximum length of a Publishing.publicDescription field.
 */
const i32    EDAM_PUBLISHING_DESCRIPTION_LEN_MAX = 200;
/**
 * Any public notebook's Publishing.publicDescription field must match
 * this pattern.
 * No control chars or line/paragraph separators, and can't start or
 * end with whitespace.
 */
const string EDAM_PUBLISHING_DESCRIPTION_REGEX = 
  "^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,198}[^\\p{Cc}\\p{Z}])?$";

/**
 * The minimum length of a SavedSearch.name field
 */
const i32    EDAM_SAVED_SEARCH_NAME_LEN_MIN = 1;
/**
 * The maximum length of a SavedSearch.name field
 */
const i32    EDAM_SAVED_SEARCH_NAME_LEN_MAX = 100;
/**
 * SavedSearch.name fields must match this pattern.
 * No control chars or line/paragraph separators, and can't start or
 * end with whitespace.
 */
const string EDAM_SAVED_SEARCH_NAME_REGEX =
  "^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,98}[^\\p{Cc}\\p{Z}])?$";

/**
 * The minimum length of an Evernote user password
 */
const i32    EDAM_USER_PASSWORD_LEN_MIN = 6;
/**
 * The maximum length of an Evernote user password
 */
const i32    EDAM_USER_PASSWORD_LEN_MAX = 64;
/**
 * Evernote user passwords must match this regular expression
 */
const string EDAM_USER_PASSWORD_REGEX = 
  "^[A-Za-z0-9!#$%&'()*+,./:;<=>?@^_`{|}~\\[\\]\\\\-]{6,64}$";


// ==================== data model collection limits ===========================

/**
 * The maximum number of Tags per Note
 */
const i32    EDAM_NOTE_TAGS_MAX = 100;

/**
 * The maximum number of Resources per Note
 */
const i32    EDAM_NOTE_RESOURCES_MAX = 1000;

/**
 * Maximum number of Tags per account
 */
const i32    EDAM_USER_TAGS_MAX = 100000;

/**
 * Maximum number of SavedSearches per account
 */
const i32    EDAM_USER_SAVED_SEARCHES_MAX = 100;

/**
 * Maximum number of Notes per user
 */
const i32    EDAM_USER_NOTES_MAX = 100000;

/**
 * Maximum number of Notebooks per user
 */
const i32    EDAM_USER_NOTEBOOKS_MAX = 100;

/**
 * Maximum number of recent email addresses that are maintained
 * (see UserAttributes.recentMailedAddresses)
 */
const i32    EDAM_USER_RECENT_MAILED_ADDRESSES_MAX = 10;

/**
 * The number of emails of any type that can be sent by a user with a Free
 * account from the service per day.  If an email is sent to two different
 * recipients, this counts as two emails.
 */
const i32    EDAM_USER_MAIL_LIMIT_DAILY_FREE = 50;

/**
 * The number of emails of any type that can be sent by a user with a Premium
 * account from the service per day.  If an email is sent to two different
 * recipients, this counts as two emails.
 */
const i32    EDAM_USER_MAIL_LIMIT_DAILY_PREMIUM = 200;

/**
 * Maximum total size of a Note that can be added to a Free account.
 * The size of a note is calculated as:
 * ENML content length (in Unicode characters) plus the sum of all resource
 * sizes (in bytes).
 */
const i32    EDAM_NOTE_SIZE_MAX_FREE = 26214400;

/**
 * Maximum total size of a Note that can be added to a Premium account.
 * The size of a note is calculated as:
 * ENML content length (in Unicode characters) plus the sum of all resource
 * sizes (in bytes).
 */
const i32    EDAM_NOTE_SIZE_MAX_PREMIUM = 52428800;

/**
 * Maximum size of a resource, in bytes, for Free accounts
 */
const i32    EDAM_RESOURCE_SIZE_MAX_FREE = 26214400;

/**
 * Maximum size of a resource, in bytes, for Premium accounts
 */
const i32    EDAM_RESOURCE_SIZE_MAX_PREMIUM = 52428800; 

/**
 * Maximum number of linked notebooks per account
 */
const i32   EDAM_USER_LINKED_NOTEBOOK_MAX = 100;

/**
 * Maximum number of shared notebooks per notebook
 */
const i32   EDAM_NOTEBOOK_SHARED_NOTEBOOK_MAX = 100;
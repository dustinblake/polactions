/*
 * Copyright (c) 2007-2008 by Evernote Corporation, All rights reserved.
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
 * This file contains the EDAM protocol interface for operations to query
 * and/or authenticate users.
 */

include "UserStore.thrift"
include "Types.thrift"
include "Errors.thrift"
include "Limits.thrift"

namespace java com.evernote.edam.notestore
namespace csharp Evernote.EDAM.NoteStore
namespace py evernote.edam.notestore
namespace cpp evernote.edam
namespace rb Evernote.EDAM.NoteStore
namespace php edam_notestore
namespace cocoa EDAM
namespace perl EDAMNoteStore


/**
 * This structure encapsulates the information about the state of the
 * user's account for the purpose of "state based" synchronization.
 *<dl>
 * <dt>currentTime</dt>
 *   <dd>
 *   The server's current date and time.
 *   </dd>
 *
 * <dt>fullSyncBefore</dt>
 *   <dd>
 *   The cutoff date and time for client caches to be
 *   updated via incremental synchronization.  Any clients that were last 
 *   synched with the server before this date/time must do a full resync of all
 *   objects.  This cutoff point will change over time as archival data is
 *   deleted or special circumstances on the service require resynchronization.
 *   </dd>
 *
 * <dt>updateCount</dt>
 *   <dd>
 *   Indicates the total number of transactions that have
 *   been committed within the account.  This reflects (for example) the
 *   number of discrete additions or modifications that have been made to
 *   the data in this account (tags, notes, resources, etc.).
 *   This number is the "high water mark" for Update Sequence Numbers (USN)
 *   within the account.
 *   </dd>
 *
 * <dt>uploaded</dt>
 *   <dd>
 *   The total number of bytes that have been uploaded to
 *   this account in the current monthly period.  This can be compared against
 *   Accounting.uploadLimit (from the UserStore) to determine how close the user
 *   is to their monthly upload limit.
 *   </dd>
 * </dl>
 */
struct SyncState {
  1:  required  Types.Timestamp currentTime,
  2:  required  Types.Timestamp fullSyncBefore,
  3:  required  i32 updateCount,
  4:  optional  i64 uploaded
}


/**
 * This structure is given out by the NoteStore when a client asks to
 * receive the current state of an account.  The client asks for the server's
 * state one chunk at a time in order to allow clients to retrieve the state
 * of a large account without needing to transfer the entire account in
 * a single message.
 *
 * The server always gives SyncChunks using an ascending series of Update
 * Sequence Numbers (USNs).
 *
 *<dl>
 * <dt>currentTime</dt>
 *   <dd>
 *   The server's current date and time.
 *   </dd>
 *
 * <dt>chunkHighUSN</dt>
 *   <dd>
 *   The highest USN for any of the data objects represented
 *   in this sync chunk.  If there are no objects in the chunk, this will not be
 *   set.
 *   </dd>
 *
 * <dt>updateCount</dt>
 *   <dd>
 *   The total number of updates that have been performed in
 *   the service for this account.  This is equal to the highest USN within the
 *   account at the point that this SyncChunk was generated.  If updateCount
 *   and chunkHighUSN are identical, that means that this is the last chunk
 *   in the account ... there is no more recent information.
 *   </dd>
 *
 * <dt>notes</dt>
 *   <dd>
 *   If present, this is a list of non-expunged notes that
 *   have a USN in this chunk.  This will include notes that are "deleted"
 *   but not expunged (i.e. in the trash).  The notes will include their list
 *   of tags and resources, but the resource content and recognition data
 *   will not be supplied.
 *   </dd>
 *
 * <dt>notebooks</dt>
 *   <dd>
 *   If present, this is a list of non-expunged notebooks that
 *   have a USN in this chunk.  This will include notebooks that are "deleted"
 *   but not expunged (i.e. in the trash).
 *   </dd>
 *
 * <dt>tags</dt>
 *   <dd>
 *   If present, this is a list of the non-expunged tags that have a
 *   USN in this chunk.
 *   </dd>
 *
 * <dt>searches</dt>
 *   <dd>
 *   If present, this is a list of non-expunged searches that
 *   have a USN in this chunk.
 *   </dd>
 *
 * <dt>resources</dt>
 *   <dd>
 *   If present, this is a list of the non-expunged resources
 *   that have a USN in this chunk.  This will include the metadata for each
 *   resource, but not its binary contents or recognition data, which must be
 *   retrieved separately.
 *   </dd>
 *
 * <dt>expungedNotes</dt>
 *   <dd>
 *   If present, the GUIDs of all of the notes that were
 *   permanently expunged in this chunk.
 *   </dd>
 *
 * <dt>expungedNotebooks</dt>
 *   <dd>
 *   If present, the GUIDs of all of the notebooks that
 *   were permanently expunged in this chunk.  When a notebook is expunged,
 *   this implies that all of its child notes (and their resources) were
 *   also expunged.
 *   </dd>
 *
 * <dt>expungedTags</dt>
 *   <dd>
 *   If present, the GUIDs of all of the tags that were
 *   permanently expunged in this chunk.
 *   </dd>
 *
 * <dt>expungedSearches</dt>
 *   <dd>
 *   If present, the GUIDs of all of the saved searches
 *   that were permanently expunged in this chunk.
 *   </dd>
 * </dl>
 */
struct SyncChunk {
  1:  required  Types.Timestamp currentTime,
  2:  optional  i32 chunkHighUSN,
  3:  required  i32 updateCount,
  4:  optional  list<Types.Note> notes,
  5:  optional  list<Types.Notebook> notebooks,
  6:  optional  list<Types.Tag> tags,
  7:  optional  list<Types.SavedSearch> searches,
  8:  optional  list<Types.Resource> resources, 
  9:  optional  list<Types.Guid> expungedNotes,
  10: optional  list<Types.Guid> expungedNotebooks,
  11: optional  list<Types.Guid> expungedTags,
  12: optional  list<Types.Guid> expungedSearches,
}


/**
 * A list of criteria that are used to indicate which notes are desired from
 * the account.  This is used in queries to the NoteStore to determine
 * which notes should be retrieved.
 *
 *<dl>
 * <dt>order</dt>
 *   <dd>
 *   The NoteSortOrder value indicating what criterion should be
 *   used to sort the results of the filter.
 *   </dd>
 *
 * <dt>ascending</dt>
 *   <dd>
 *   If true, the results will be ascending in the requested
 *   sort order.  If false, the results will be descending.
 *   </dd>
 *
 * <dt>words</dt>
 *   <dd>
 *   The string query containing keywords to match, if present.
 *   </dd>
 *
 * <dt>notebookGuid</dt>
 *   <dd>
 *   If present, the Guid of the notebook that must contain
 *   the notes.
 *   </dd>
 *
 * <dt>tagGuids</dt>
 *   <dd>
 *   If present, the list of tags (by GUID) that must be present
 *   on the notes.
 *   </dd>
 *
 * <dt>timeZone</dt>
 *   <dd>
 *   The zone ID for the user, which will be used to interpret
 *   any dates or times in the queries that do not include their desired zone
 *   information.
 *   For example, if a query requests notes created "yesterday", this
 *   will be evaluated from the provided time zone, if provided.
 *   The format must be encoded as a standard zone ID such as
 *   "America/Los_Angeles".
 *   </dd>
 *
 * <dt>inactive</dt>
 *   <dd>
 *   If true, then only notes that are not active (i.e. notes in
 *   the Trash) will be returned. Otherwise, only active notes will be returned.
 *   There is no way to find both active and inactive notes in a single query.
 *   </dd>
 * </dl>
 */
struct NoteFilter {
  // 1: optional  Types.NoteSortOrder order,
  1: optional  i32 order,  // Should be one of the NoteSortOrder values
  2: optional  bool ascending,
  3: optional  string words,
  4: optional  Types.Guid notebookGuid,
  5: optional  list<Types.Guid> tagGuids,
  6: optional  string timeZone,
  7: optional  bool inactive
}


/**
 * A small structure for returning a list of notes out of a larger set.
 *
 *<dl>
 * <dt>startIndex</dt>
 *   <dd>
 *   The starting index within the overall set of notes.  This
 *   is also the number of notes that are "before" this list in the set.
 *   </dd>
 *
 * <dt>totalNotes</dt>
 *   <dd>
 *   The number of notes in the larger set.  This can be used
 *   to calculate how many notes are "after" this note in the set.
 *   (I.e.  remaining = totalNotes - (startIndex + notes.length)  )
 *   </dd>
 *
 * <dt>notes</dt>
 *   <dd>
 *   The list of notes from this range.  The Notes will include all
 *   metadata (attributes, resources, etc.), but will not include the ENML
 *   content of the note or the binary contents of any resources.
 *   </dd>
 *
 * <dt>stoppedWords</dt>
 *   <dd>
 *   If the NoteList was produced using a text based search
 *   query that included words that are not indexed or searched by the service,
 *   this will include a list of those ignored words.
 *   </dd>
 *
 * <dt>searchedWords</dt>
 *   <dd>
 *   If the NoteList was produced using a text based search
 *   query that included viable search words or quoted expressions, this will
 *   include a list of those words.  Any stopped words will not be included
 *   in this list.
 *   </dd>
 * </dl>
 */
struct NoteList {
  1: required  i32 startIndex,
  2: required  i32 totalNotes,
  3: required  list<Types.Note> notes,
  4: optional  list<string> stoppedWords,
  5: optional  list<string> searchedWords
}


/**
 * A data structure representing the number of notes for each notebook
 * and tag with a non-zero set of applicable notes.
 *
 *<dl>
 * <dt>notebookCounts</dt>
 *   <dd>
 *   A mapping from the Notebook GUID to the number of
 *   notes (from some selection) that are in the corresponding notebook.
 *   </dd>
 *
 * <dt>tagCounts</dt>
 *   <dd>
 *   A mapping from the Tag GUID to the number of notes (from some
 *   selection) that have the corresponding tag.
 *   </dd>
 *
 * <dt>trashCount</dt>
 *   <dd>
 *   If this is set, then this is the number of notes that are in the trash.
 *   If this is not set, then the number of notes in the trash hasn't been
 *   reported.  (I.e. if there are no notes in the trash, this will be set
 *   to 0.)
 *   </dd>
 * </dl>
 */
struct NoteCollectionCounts {
  1: optional  map<Types.Guid, i32> notebookCounts,
  2: optional  map<Types.Guid, i32> tagCounts,
  3: optional  i32 trashCount
}

/**
 * Information for tracking the display of a particular ad by a client.
 *
 * <dl>
 *  <dt>adId</dt>
 *    <dd>
 *      The identifier for this ad, from a previous Ad.id given to the client
 *    </dd>
 *
 *  <dt>impressionCount</dt>
 *    <dd>
 *      The number of times this ad was displayed since the last successful
 *      ad retrieval.  The client should only report times the ad was selected
 *      when the client was visible.
 *    </dd>
 *
 *  <dt>impressionTime</dt>
 *    <dd>
 *      The number of seconds that the client displayed the advertisement since
 *      the last successful ad retrieval.  This corresponds to the seconds that
 *      the client application was visible.
 *    </dd>
 * </dl>
 */
struct AdImpressions {
  1:  required  i32 adId,
  2:  required  i32 impressionCount,
  3:  required  i32 impressionTime
}

/**
 * Parameters that will be given by a client to the service when it requests
 * a set of advertisements to display.  If any of these values are omitted,
 * the service will use default values.
 *
 * <dl>
 *  <dt>clientLanguage</dt>
 *    <dd>
 *      The ISO 639-1 language code for the primary language for the client.
 *      If omitted, English will be assumed ('en').
 *    </dd>
 *
 *  <dt>impressions</dt>
 *    <dd>
 *      A list of the impression counts and total display time for the ads
 *      that were displayed in the last day.
 *    </dd>
 *
 *  <dt>supportHtml</dt>
 *    <dd>
 *      If true, the client requesting the ads supports ads specified via
 *      general HTML (with rich media, Javascript, etc.).
 *    </dd>
 * </dl>
 */
struct AdParameters {
  2:  optional  string  clientLanguage,
  4:  optional  list<AdImpressions>  impressions,
  5:  optional  bool supportHtml
}

/**
 * Parameters that must be given to the NoteStore emailNote call. These allow
 * the caller to specify the note to send, the recipient addresses, etc.
 *
 * <dl>
 *  <dt>guid</dt>
 *    <dd>
 *      If set, this must be the GUID of a note within the user's account that
 *      should be retrieved from the service and sent as email.  If not set,
 *      the 'note' field must be provided instead.
 *    </dd>
 *
 *  <dt>note</dt>
 *    <dd>
 *      If the 'guid' field is not set, this field must be provided, including
 *      the full contents of the note note (and all of its Resources) to send.
 *      This can be used for a Note that as not been created in the service,
 *      for example by a local client with local notes.
 *    </dd>
 *
 *  <dt>toAddresses</dt>
 *    <dd>
 *      If provided, this should contain a list of the SMTP email addresses
 *      that should be included in the "To:" line of the email.
 *      Callers must specify at least one "to" or "cc" email address.
 *    </dd>
 *
 *  <dt>ccAddresses</dt>
 *    <dd>
 *      If provided, this should contain a list of the SMTP email addresses
 *      that should be included in the "Cc:" line of the email.
 *      Callers must specify at least one "to" or "cc" email address.
 *    </dd>
 *
 *  <dt>subject</dt>
 *    <dd>
 *      If provided, this should contain the subject line of the email that
 *      will be sent.  If not provided, the title of the note will be used
 *      as the subject of the email.
 *    </dd>
 *
 *  <dt>message</dt>
 *    <dd>
 *      If provided, this is additional personal text that should be included
 *      into the email as a message from the owner to the recipient(s).
 *    </dd>
 * </dl> 
 */
struct NoteEmailParameters {
  1:  optional  string guid,
  2:  optional  Types.Note note,
  3:  optional  list<string> toAddresses,
  4:  optional  list<string> ccAddresses,
  5:  optional  string subject, 
  6:  optional  string message
}

/**
 * Service:  NoteStore
 * <p>
 * The NoteStore service is used by EDAM clients to exchange information
 * about the collection of notes in an account.  This is primarily used for
 * synchronization, but could also be used by a "thin" client without a full
 * local cache.
 * </p><p>
 * All functions take an "authenticationToken" parameter, which is the
 * value returned by the UserStore which permits access to the account.
 * This parameter is mandatory for all functions.
 * </p>
 *
 * Calls which require an authenticationToken may throw an EDAMUserException
 * for the following reasons: 
 *  <ul>
 *   <li> AUTH_EXPIRED "authenticationToken" - token has expired
 *   </li>
 *   <li> BAD_DATA_FORMAT "authenticationToken" - token is malformed
 *   </li>
 *   <li> DATA_REQUIRED "authenticationToken" - token is empty
 *   </li>
 *   <li> INVALID_AUTH "authenticationToken" - token signature is invalid
 *   </li>
 * </ul>
 */
service NoteStore {

  /*========== Synchronization functions for caching clients ===========*/

  /**
   * Asks the NoteStore to provide information about the status of the user
   * account corresponding to the provided authentication token.
   */
  SyncState getSyncState(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * Asks the NoteStore to provide the state of the account in order of
   * last modification.  This request retrieves one block of the server's
   * state so that a client can make several small requests against a large
   * account rather than getting the entire state in one big message.
   * 
   * @param afterUSN 
   *   The client can pass this value to ask only for objects that
   *   have been updated after a certain point.  This allows the client to
   *   receive updates after its last checkpoint rather than doing a full
   *   synchronization on every pass.  The default value of "0" indicates
   *   that the client wants to get objects from the start of the account.
   * 
   * @param maxEntries
   *   The maximum number of modified objects that should be
   *   returned in the result SyncChunk.  This can be used to limit the size
   *   of each individual message to be friendly for network transfer.
   * 
   * @param fullSyncOnly
   *   If true, then the client only wants initial data for a full sync.
   *   In this case, the service will not return any expunged objects,
   *   and will not return any Resources, since these are also provided
   *   in their corresponding Notes.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "afterUSN" - if negative
   *   </li>
   *   <li> BAD_DATA_FORMAT "maxEntries" - if less than 1
   *   </li>
   * </ul>
   */
  SyncChunk getSyncChunk(1: string authenticationToken,
                         2: i32 afterUSN,
                         3: i32 maxEntries,
                         4: bool fullSyncOnly)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),



  /*============= General account manipulation functions ===============*/

  /**
   * Returns a list of all of the notebooks in the account.
   */
  list<Types.Notebook> listNotebooks(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * Returns the current state of the notebook with the provided GUID.
   * The notebook may be active or deleted (but not expunged).
   *
   * @param guid
   *   The GUID of the notebook to be retrieved.  
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Notebook.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Notebook" - private notebook, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Notebook.guid" - tag not found, by GUID
   *   </li>
   * </ul>
   */
  Types.Notebook getNotebook(1: string authenticationToken,
                             2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Returns the notebook that should be used to store new notes in the
   * user's account when no other notebooks are specified.
   */
  Types.Notebook getDefaultNotebook(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * Asks the service to make a notebook with the provided name.
   *
   * @param notebook
   *   The desired fields for the notebook must be provided on this
   *   object.  The name of the notebook must be set, and either the 'active'
   *   or 'defaultNotebook' fields may be set by the client at creation.
   *   If a notebook exists in the account with the same name (via 
   *   case-insensitive compare), this will throw an EDAMUserException.
   *
   * @return
   *   The newly created Notebook.  The server-side GUID will be
   *   saved in this object's 'guid' field.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Notebook.name" - invalid length or pattern
   *   </li>
   *   <li> BAD_DATA_FORMAT "Publishing.uri" - if publishing set but bad uri
   *   </li>
   *   <li> BAD_DATA_FORMAT "Publishing.publicDescription" - if too long
   *   </li>
   *   <li> DATA_CONFLICT "Notebook.name" - name already in use
   *   </li>
   *   <li> DATA_CONFLICT "Publishing.uri" - if URI already in use
   *   </li>
   *   <li> DATA_REQUIRED "Publishing.uri" - if publishing set but uri missing
   *   </li>
   *   <li> LIMIT_REACHED "Notebook" - at max number of notebooks
   *   </li>
   * </ul>
   */
  Types.Notebook createNotebook(1: string authenticationToken,
                                2: Types.Notebook notebook)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * Submits notebook changes to the service.  The provided data must include
   * the notebook's guid field for identification.
   *
   * @param notebook
   *   The notebook object containing the requested changes.
   *
   * @return
   *   The Update Sequence Number for this change within the account.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Notebook.name" - invalid length or pattern
   *   </li>
   *   <li> BAD_DATA_FORMAT "Publishing.uri" - if publishing set but bad uri
   *   </li>
   *   <li> BAD_DATA_FORMAT "Publishing.publicDescription" - if too long
   *   </li>
   *   <li> DATA_CONFLICT "Notebook.name" - name already in use
   *   </li>
   *   <li> DATA_CONFLICT "Publishing.uri" - if URI already in use
   *   </li>
   *   <li> DATA_REQUIRED "Publishing.uri" - if publishing set but uri missing
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Notebook.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  i32 updateNotebook(1: string authenticationToken,
                     2: Types.Notebook notebook)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Permanently removes the notebook, and all of its content notes,
   * from the service.  After this action, the notebook is no longer
   * available for undeletion, etc. 
   *
   * @param guid
   *   The GUID of the notebook to delete.
   *
   * @return
   *   The Update Sequence Number for this change within the account.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Notebook.guid" - if the parameter is missing
   *   </li>
   *   <li> LIMIT_REACHED "Notebook" - trying to expunge the last Notebook
   *   </li>
   *   <li> PERMISSION_DENIED "Notebook" - private notebook, user doesn't own
   *   </li>
   * </ul>
   */
  i32 expungeNotebook(1: string authenticationToken,
                      2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Returns a list of the tags in the account.  Evernote does not support
   * the undeletion of tags, so this will only include active tags.
   */
  list<Types.Tag> listTags(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * Returns a list of the tags that are applied to at least one note within
   * the provided notebook.  If the notebook is public, the authenticationToken
   * may be ignored.
   *
   * @param notebookGuid
   *    the GUID of the notebook to use to find tags
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Notebook.guid" - notebook not found by GUID
   *   </li>
   * </ul>
   */
  list<Types.Tag> listTagsByNotebook(1: string authenticationToken,
                                     2: Types.Guid notebookGuid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Returns the current state of the Tag with the provided GUID.
   *
   * @param guid
   *   The GUID of the tag to be retrieved.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Tag.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Tag" - private Tag, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Tag.guid" - tag not found, by GUID
   *   </li>
   * </ul>
   */
  Types.Tag getTag(1: string authenticationToken,
                   2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),
    
  /**
   * Asks the service to make a tag with a set of information.
   *
   * @param tag
   *   The desired list of fields for the tag are specified in this
   *   object.  The caller must specify the tag name, and may provide 
   *   the parentGUID.
   *
   * @return
   *   The newly created Tag.  The server-side GUID will be
   *   saved in this object.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Tag.name" - invalid length or pattern
   *   </li>
   *   <li> BAD_DATA_FORMAT "Tag.parentGuid" - malformed GUID
   *   </li>
   *   <li> DATA_CONFLICT "Tag.name" - name already in use
   *   </li>
   *   <li> LIMIT_REACHED "Tag" - at max number of tags
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Tag.parentGuid" - not found, by GUID
   *   </li>
   * </ul>
   */
  Types.Tag createTag(1: string authenticationToken,
                      2: Types.Tag tag)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Submits tag changes to the service.  The provided data must include
   * the tag's guid field for identification.  The service will apply
   * updates to the following tag fields:  name, parentGuid
   *
   * @param tag
   *   The tag object containing the requested changes.
   *
   * @return
   *   The Update Sequence Number for this change within the account.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Tag.name" - invalid length or pattern
   *   </li>
   *   <li> BAD_DATA_FORMAT "Tag.parentGuid" - malformed GUID
   *   </li>
   *   <li> DATA_CONFLICT "Tag.name" - name already in use
   *   </li>
   *   <li> DATA_CONFLICT "Tag.parentGuid" - can't set parent: circular
   *   </li>
   *   <li> PERMISSION_DENIED "Tag" - user doesn't own tag
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Tag.guid" - tag not found, by GUID
   *   </li>
   *   <li> "Tag.parentGuid" - parent not found, by GUID
   *   </li>
   * </ul>
   */
  i32 updateTag(1: string authenticationToken,
                2: Types.Tag tag)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Removes the provided tag from every note that is currently tagged with
   * this tag.  If this operation is successful, the tag will still be in
   * the account, but it will not be tagged on any notes.
   *
   * This function is not indended for use by full synchronizing clients, since
   * it does not provide enough result information to the client to reconcile
   * the local state without performing a follow-up sync from the service.  This
   * is intended for "thin clients" that need to efficiently support this as
   * a UI operation.
   *
   * @param guid
   *   The GUID of the tag to remove from all notes.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Tag.guid" - if the guid parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Tag" - user doesn't own tag
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Tag.guid" - tag not found, by GUID
   *   </li>
   * </ul>
   */
  void untagAll(1: string authenticationToken,
                2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Permanently deletes the tag with the provided GUID, if present.
   *
   * @param guid
   *   The GUID of the tag to delete.
   *
   * @return
   *   The Update Sequence Number for this change within the account.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Tag.guid" - if the guid parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Tag" - user doesn't own tag
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Tag.guid" - tag not found, by GUID
   *   </li>
   * </ul>
   */
  i32 expungeTag(1: string authenticationToken,
                 2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),


  /**
   * Returns a list of the searches in the account.  Evernote does not support
   * the undeletion of searches, so this will only include active searches.
   */
  list<Types.SavedSearch> listSearches(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),
  
  /**
   * Returns the current state of the search with the provided GUID.
   *
   * @param guid
   *   The GUID of the search to be retrieved.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "SavedSearch.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "SavedSearch" - private Tag, user doesn't own
   *   </li>
   * </ul>
   */
  Types.SavedSearch getSearch(1: string authenticationToken,
                              2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Asks the service to make a saved search with a set of information.
   *
   * @param search
   *   The desired list of fields for the search are specified in this
   *   object.  The caller must specify the
   *   name, query, and format of the search.
   *
   * @return
   *   The newly created SavedSearch.  The server-side GUID will be
   *   saved in this object.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "SavedSearch.name" - invalid length or pattern
   *   </li>
   *   <li> BAD_DATA_FORMAT "SavedSearch.query" - invalid length
   *   </li>
   *   <li> BAD_DATA_FORMAT "SavedSearch.format" - not a valid QueryFormat value
   *   </li>
   *   <li> DATA_CONFLICT "SavedSearch.name" - name already in use
   *   </li>
   *   <li> LIMIT_REACHED "SavedSearch" - at max number of searches
   *   </li>
   * </ul>
   */
  Types.SavedSearch createSearch(1: string authenticationToken,
                                 2: Types.SavedSearch search)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * Submits search changes to the service.  The provided data must include
   * the search's guid field for identification.  The service will apply
   * updates to the following search fields:  name, query, and format
   *
   * @param search
   *   The search object containing the requested changes.
   *
   * @return
   *   The Update Sequence Number for this change within the account.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "SavedSearch.name" - invalid length or pattern
   *   </li>
   *   <li> BAD_DATA_FORMAT "SavedSearch.query" - invalid length
   *   </li>
   *   <li> BAD_DATA_FORMAT "SavedSearch.format" - not a valid QueryFormat value
   *   </li>
   *   <li> DATA_CONFLICT "SavedSearch.name" - name already in use
   *   </li>
   *   <li> PERMISSION_DENIED "SavedSearch" - user doesn't own tag
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "SavedSearch.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  i32 updateSearch(1: string authenticationToken,
                   2: Types.SavedSearch search)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Permanently deletes the search with the provided GUID, if present.
   *
   * @param guid
   *   The GUID of the search to delete.
   *
   * @return
   *   The Update Sequence Number for this change within the account.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "SavedSearch.guid" - if the guid parameter is empty
   *   </li>
   *   <li> PERMISSION_DENIED "SavedSearch" - user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "SavedSearch.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  i32 expungeSearch(1: string authenticationToken,
                    2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Used to find a set of the notes from a user's account based on various
   * criteria specified via a NoteFilter object.
   * The Notes (and any embedded Resources) will have empty Data bodies for
   * contents, resource data, and resource recognition fields.  These values
   * must be retrieved individually.
   *
   * @param authenticationToken
   *   Must be a valid token for the user's account unless the NoteFilter
   *   'notebookGuid' is the GUID of a public notebook.
   *
   * @param filter
   *   The list of criteria that will constrain the notes to be returned.
   *
   * @param offset
   *   The numeric index of the first note to show within the sorted
   *   results.  The numbering scheme starts with "0".  This can be used for
   *   pagination.
   *
   * @param maxNotes
   *   The most notes to return in this query.  The service will
   *   either return this many notes or the end of the notebook, whichever is
   *   shorter.
   *
   * @return
   *   The list of notes that match the criteria.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "offset" - not between 0 and EDAM_USER_NOTES_MAX
   *   </li>
   *   <li> BAD_DATA_FORMAT "maxNotes" - not between 0 and EDAM_USER_NOTES_MAX
   *   </li>
   *   <li> BAD_DATA_FORMAT "NoteFilter.notebookGuid" - if malformed
   *   </li>
   *   <li> BAD_DATA_FORMAT "NoteFilter.tagGuids" - if any are malformed
   *   </li>
   *   <li> BAD_DATA_FORMAT "NoteFilter.words" - if search string too long
   *   </li>
   * </ul>
   */
  NoteList findNotes(1: string authenticationToken,
                     2: NoteFilter filter,
                     3: i32 offset,
                     4: i32 maxNotes)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * This function is used to determine how many notes are found for each
   * notebook and tag in the user's account, given a current set of filter
   * parameters that determine the current selection.  This function will
   * return a structure that gives the note count for each notebook and tag
   * that has at least one note under the requested filter.  Any notebook or
   * tag that has zero notes in the filtered set will not be listed in the
   * reply to this function (so they can be assumed to be 0).
   *
   * @param authenticationToken
   *   Must be a valid token for the user's account unless the NoteFilter
   *   'notebookGuid' is the GUID of a public notebook.
   *
   * @param filter
   *   The note selection filter that is currently being applied.  The note
   *   counts are to be calculated with this filter applied to the total set
   *   of notes in the user's account.
   *
   * @param withTrash
   *   If true, then the NoteCollectionCounts.trashCount will be calculated
   *   and supplied in the reply. Otherwise, the trash value will be omitted.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "NoteFilter.notebookGuid" - if malformed
   *   </li>
   *   <li> BAD_DATA_FORMAT "NoteFilter.notebookGuids" - if any are malformed
   *   </li>
   *   <li> BAD_DATA_FORMAT "NoteFilter.words" - if search string too long
   *   </li>
   * </ul>
   */
  NoteCollectionCounts findNoteCounts(1: string authenticationToken,
  	                                  2: NoteFilter filter,
  	                                  3: bool withTrash)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * Returns the current state of the note in the service with the provided
   * GUID.  The ENML contents of the note will only be provided if the
   * 'withContent' parameter is true.  The service will include the meta-data
   * for each resource in the note, but the binary contents of the resources
   * and their recognition data will be omitted.
   * If the Note is found in a public notebook, the authenticationToken
   * will be ignored (so it could be an empty string).
   *
   * @param guid
   *   The GUID of the note to be retrieved.
   *
   * @param withContent
   *   If true, the note will include the ENML contents of its
   *   'content' field.
   *
   * @param withResourcesData
   *   If true, any Resource elements in this Note will include the binary
   *   contents of their 'data' field's body.
   *
   * @param withResourcesRecognition
   *   If true, any Resource elements will include the binary contents of the
   *   'recognition' field's body if recognition data is present.
   *
   * @param withResourcesAlternateData
   *   If true, any Resource elements in this Note will include the binary
   *   contents of their 'alternateData' fields' body, if an alternate form
   *   is present.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Note.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Note" - private note, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Note.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  Types.Note getNote(1: string authenticationToken,
                     2: Types.Guid guid,
                     3: bool withContent,
                     4: bool withResourcesData,
                     5: bool withResourcesRecognition,
                     6: bool withResourcesAlternateData)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Returns XHTML contents of the note with the provided GUID.
   * If the Note is found in a public notebook, the authenticationToken
   * will be ignored (so it could be an empty string).
   *
   * @param guid
   *   The GUID of the note to be retrieved.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Note.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Note" - private note, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Note.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  string getNoteContent(1: string authenticationToken,
                        2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Returns a list of the names of the tags for the note with the provided
   * guid.  This can be used with authentication to get the tags for a
   * user's own note, or can be used without valid authentication to retrieve
   * the names of the tags for a note in a public notebook. 
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Note.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Note" - private note, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Note.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  list<string> getNoteTagNames(1: string authenticationToken,
                               2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Asks the service to make a note with the provided set of information.
   *
   * @param note
   *   A Note object containing the desired fields to be populated on
   *   the service.
   *
   * @return
   *   The newly created Note from the service.  The server-side
   *   GUIDs for the Note and any Resources will be saved in this object.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Note.title" - invalid length or pattern
   *   </li>
   *   <li> BAD_DATA_FORMAT "Note.content" - invalid length for ENML content
   *   </li>
   *   <li> BAD_DATA_FORMAT "Resource.mime" - invalid resource MIME type
   *   </li>
   *   <li> BAD_DATA_FORMAT "NoteAttributes.*" - bad resource string
   *   </li>
   *   <li> BAD_DATA_FORMAT "ResourceAttributes.*" - bad resource string
   *   </li>
   *   <li> DATA_CONFLICT "Note.deleted" - deleted time set on active note
   *   </li>
   *   <li> DATA_REQUIRED "Resource.data" - resource data body missing
   *   </li>
   *   <li> ENML_VALIDATION "*" - note content doesn't validate against DTD
   *   </li>
   *   <li> LIMIT_REACHED "Note" - at max number per account
   *   </li>
   *   <li> LIMIT_REACHED "Note.size" - total note size too large
   *   </li>
   *   <li> LIMIT_REACHED "Note.resources" - too many resources on Note
   *   </li>
   *   <li> LIMIT_REACHED "Note.tagGuids" - too many Tags on Note
   *   </li>
   *   <li> LIMIT_REACHED "Resource.data.size" - resource too large
   *   </li>
   *   <li> LIMIT_REACHED "NoteAttribute.*" - attribute string too long
   *   </li>
   *   <li> LIMIT_REACHED "ResourceAttribute.*" - attribute string too long
   *   </li>
   *   <li> PERMISSION_DENIED "Note.notebookGuid" - NB not owned by user
   *   </li>
   *   <li> QUOTA_REACHED "Accounting.uploadLimit" - note exceeds upload quota
   *   </li>
   *   <li> BAD_DATA_FORMAT "Tag.name" - Note.tagNames was provided, and one
   *     of the specified tags had an invalid length or pattern
   *   </li>
   *   <li> LIMIT_REACHED "Tag" - Note.tagNames was provided, and the required
   *     new tags would exceed the maximum number per account
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Note.notebookGuid" - not found, by GUID
   *   </li>
   * </ul>
   */
  Types.Note createNote(1: string authenticationToken,
                        2: Types.Note note)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Submit a set of changes to a note to the service.  The provided data
   * must include the note's guid field for identification.
   *
   * @param note
   *   A Note object containing the desired fields to be populated on
   *   the service.
   *
   * @return
   *   The metadata (no contents) for the Note on the server after the update
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Note.title" - invalid length or pattern
   *   </li>
   *   <li> BAD_DATA_FORMAT "Note.content" - invalid length for ENML body
   *   </li>
   *   <li> BAD_DATA_FORMAT "NoteAttributes.*" - bad resource string
   *   </li>
   *   <li> BAD_DATA_FORMAT "ResourceAttributes.*" - bad resource string
   *   </li>
   *   <li> BAD_DATA_FORMAT "Resource.mime" - invalid resource MIME type
   *   </li>
   *   <li> DATA_CONFLICT "Note.deleted" - deleted time set on active note
   *   </li>
   *   <li> DATA_REQUIRED "Resource.data" - resource data body missing
   *   </li>
   *   <li> ENML_VALIDATION "*" - note content doesn't validate against DTD
   *   </li>
   *   <li> LIMIT_REACHED "Note.tagGuids" - too many Tags on Note
   *   </li>
   *   <li> LIMIT_REACHED "Note.resources" - too many resources on Note
   *   </li>
   *   <li> LIMIT_REACHED "Note.size" - total note size too large
   *   </li>
   *   <li> LIMIT_REACHED "Resource.data.size" - resource too large
   *   </li>
   *   <li> LIMIT_REACHED "NoteAttribute.*" - attribute string too long
   *   </li>
   *   <li> LIMIT_REACHED "ResourceAttribute.*" - attribute string too long
   *   </li>
   *   <li> PERMISSION_DENIED "Note" - user doesn't own
   *   </li>
   *   <li> PERMISSION_DENIED "Note.notebookGuid" - user doesn't own destination
   *   </li>
   *   <li> QUOTA_REACHED "Accounting.uploadLimit" - note exceeds upload quota
   *   </li>
   *   <li> BAD_DATA_FORMAT "Tag.name" - Note.tagNames was provided, and one
   *     of the specified tags had an invalid length or pattern
   *   </li>
   *   <li> LIMIT_REACHED "Tag" - Note.tagNames was provided, and the required
   *     new tags would exceed the maximum number per account
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Note.guid" - note not found, by GUID
   *   </li>
   *   <li> "Note.notebookGuid" - if notebookGuid provided, but not found 
   *   </li>
   * </ul>
   */
  Types.Note updateNote(1: string authenticationToken,
                        2: Types.Note note)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Permanently removes the Note, and all of its Resources,
   * from the service.
   *
   * @param guid
   *   The GUID of the note to delete.
   *
   * @return
   *   The Update Sequence Number for this change within the account.
   *
   * @throws EDAMUserException <ul>
   *   <li> PERMISSION_DENIED "Note" - user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Note.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  i32 expungeNote(1: string authenticationToken,
                  2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Permanently removes a list of Notes, and all of their Resources, from
   * the service.  This should be invoked with a small number of Note GUIDs
   * (e.g. 100 or less) on each call.  To expunge a larger number of notes,
   * call this method multiple times.  This should also be used to reduce the
   * number of Notes in a notebook before calling expungeNotebook() or
   * in the trash before calling expungeInactiveNotes(), since these calls may
   * be prohibitively slow if there are more than a few hundred notes.
   * If an exception is thrown for any of the GUIDs, then none of the notes
   * will be deleted.  I.e. this call can be treated as an atomic transaction.
   *
   * @param noteGuids
   *   The list of GUIDs for the Notes to remove.
   *
   * @return
   *   The account's updateCount at the end of this operation
   *
   * @throws EDAMUserException <ul>
   *   <li> PERMISSION_DENIED "Note" - user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Note.guid" - not found, by GUID
   *   </li>
   * </ul>   
   */
  i32 expungeNotes(1: string authenticationToken,
                    2: list<Types.Guid> noteGuids)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Permanently removes all of the Notes that are currently marked as
   * inactive.  This is equivalent to "emptying the trash", and these Notes
   * will be gone permanently.
   * <p/>
   * This operation may be relatively slow if the account contains a large
   * number of inactive Notes. 
   *
   * @return
   *    The number of notes that were expunged.
   */
  i32 expungeInactiveNotes(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),  

  /**
   * Performs a deep copy of the Note with the provied GUID 'noteGuid' into
   * the Notebook with the provided GUID 'toNotebookGuid'.
   * The caller must be the owner of both the Note and the Notebook.
   * This creates a new Note in the destination Notebook with new content and
   * Resources that match all of the content and Resources from the original
   * Note, but with new GUID identifiers.  
   * The original Note is not modified by this operation.
   * The copied note is considered as an "upload" for the purpose of upload
   * transfer limit calculation, so its size is added to the upload count for
   * the owner.
   *
   * @param noteGuid
   *   The GUID of the Note to copy.
   *
   * @param toNotebookGuid
   *   The GUID of the Notebook that should receive the new Note.
   *
   * @return
   *   The metadata for the new Note that was created.  This will include the
   *   new GUID for this Note (and any copied Resources), but will not include
   *   the content body or the binary bodies of any Resources.
   *
   * @throws EDAMUserException <ul>
   *   <li> LIMIT_REACHED "Note" - at max number per account
   *   </li>
   *   <li> PERMISSION_DENIED "Notebook.guid" - destination not owned by user
   *   </li>
   *   <li> PERMISSION_DENIED "Note" - user doesn't own
   *   </li>
   *   <li> QUOTA_REACHED "Accounting.uploadLimit" - note exceeds upload quota
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Notebook.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  Types.Note copyNote(1: string authenticationToken,
                      2: Types.Guid noteGuid,
                      3: Types.Guid toNotebookGuid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Returns the current state of the resource in the service with the
   * provided GUID.
   * If the Resource is found in a public notebook, the authenticationToken
   * will be ignored (so it could be an empty string).
   *
   * @param guid
   *   The GUID of the resource to be retrieved.
   *
   * @param withData
   *   If true, the Resource will include the binary contents of the
   *   'data' field's body.
   *
   * @param withRecognition
   *   If true, the Resource will include the binary contents of the
   *   'recognition' field's body if recognition data is present.
   *
   * @param withAttributes
   *   If true, the Resource will include the attributes
   *
   * @param withAlternateData
   *   If true, the Resource will include the binary contents of the
   *   'alternateData' field's body, if an alternate form is present.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Resource.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Resource" - private resource, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Resource.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  Types.Resource getResource(1: string authenticationToken,
                             2: Types.Guid guid,
                             3: bool withData,
                             4: bool withRecognition,
                             5: bool withAttributes,
                             6: bool withAlternateData)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Submit a set of changes to a resource to the service.  This can be used
   * to update the meta-data about the resource, but cannot be used to change
   * the binary contents of the resource (including the length and hash).  These
   * cannot be changed directly without creating a new resource and removing the
   * old one via updateNote.
   *
   * @param resource
   *   A Resource object containing the desired fields to be populated on
   *   the service.  The service will attempt to update the resource with the
   *   following fields from the client:
   *   <ul>
   *      <li>guid:  must be provided to identify the resource
   *      </li>
   *      <li>mime
   *      </li>
   *      <li>width
   *      </li>
   *      <li>height
   *      </li>
   *      <li>duration
   *      </li>
   *      <li>recognition:  if this is provided, it must include the
   *          data body for the resource recognition index data and the
   *          recoFormat must be provided.  If absent,
   *          the recognition on the server won't be changed.
   *      </li>
   *      <li>attributes:  optional.  if present, the set of attributes will
   *           be replaced.
   *      </li>
   *   </ul>
   *
   * @return
   *   The Update Sequence Number of the resource after the changes have been
   *   applied.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Resource.guid" - if the parameter is missing
   *   </li>
   *   <li> BAD_DATA_FORMAT "Resource.mime" - invalid resource MIME type
   *   </li>
   *   <li> BAD_DATA_FORMAT "ResourceAttributes.*" - bad resource string
   *   </li>
   *   <li> DATA_REQUIRED "Resource.data" - resource data body missing
   *   </li>
   *   <li> LIMIT_REACHED "ResourceAttribute.*" - attribute string too long
   *   </li>
   *   <li> PERMISSION_DENIED "Resource" - private resource, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Resource.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  i32 updateResource(1: string authenticationToken,
                     2: Types.Resource resource)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Returns binary data of the resource with the provided GUID.  For
   * example, if this were an image resource, this would contain the
   * raw bits of the image.
   * If the Resource is found in a public notebook, the authenticationToken
   * will be ignored (so it could be an empty string).
   *
   * @param guid
   *   The GUID of the resource to be retrieved.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Resource.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Resource" - private resource, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Resource.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  binary getResourceData(1: string authenticationToken,
                         2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Returns the current state of a resource, referenced by containing
   * note GUID and resource content hash.
   *
   * @param noteGuid
   *   The GUID of the note that holds the resource to be retrieved.
   *
   * @param contentHash
   *   The MD5 checksum of the resource within that note.
   *
   * @param withData
   *   If true, the Resource will include the binary contents of the
   *   'data' field's body.
   *
   * @param withRecognition
   *   If true, the Resource will include the binary contents of the
   *   'recognition' field's body.
   *   
   * @param withAlternateData
   *   If true, the Resource will include the binary contents of the
   *   'alternateData' field's body, if an alternate form is present.
   *
   * @throws EDAMUserException <ul>
   *   <li> DATA_REQUIRED "Note.guid" - noteGuid param missing
   *   </li>
   *   <li> DATA_REQUIRED "Note.contentHash" - contentHash param missing
   *   </li>
   *   <li> PERMISSION_DENIED "Resource" - private resource, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Note" - not found, by guid
   *   </li>
   *   <li> "Resource" - not found, by hash
   *   </li>
   * </ul>
   */
  Types.Resource getResourceByHash(1: string authenticationToken,
                                   2: Types.Guid noteGuid,
                                   3: binary contentHash,
                                   4: bool withData,
                                   5: bool withRecognition,
                                   6: bool withAlternateData)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Returns the binary contents of the recognition index for the resource
   * with the provided GUID.  If the caller asks about a resource that has
   * no recognition data, this will throw EDAMNotFoundException.
   * If the Resource is found in a public notebook, the authenticationToken
   * will be ignored (so it could be an empty string).
   *
   * @param guid
   *   The GUID of the resource whose recognition data should be retrieved.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Resource.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Resource" - private resource, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Resource.guid" - not found, by GUID
   *   </li>
   *   <li> "Resource.recognition" - resource has no recognition
   *   </li>
   * </ul>
   */
  binary getResourceRecognition(1: string authenticationToken,
                                2: Types.Guid guid)
  	throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * If the Resource with the provided GUID has an alternate data representation
   * (indicated via the Resource.alternateData field), then this request can
   * be used to retrieve the binary contents of that alternate data file.
   * If the caller asks about a resource that has no alternate data form, this
   * will throw EDAMNotFoundException.
   *
   * @param guid
   *    The GUID of the resource whose recognition data should be retrieved.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Resource.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Resource" - private resource, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Resource.guid" - not found, by GUID
   *   </li>
   *   <li> "Resource.alternateData" - resource has no recognition
   *   </li>
   * </ul>
   */
  binary getResourceAlternateData(1: string authenticationToken,
                                  2: Types.Guid guid)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * Returns the set of attributes for the Resource with the provided GUID.
   * If the Resource is found in a public notebook, the authenticationToken
   * will be ignored (so it could be an empty string).
   *
   * @param guid
   *   The GUID of the resource whose attributes should be retrieved.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "Resource.guid" - if the parameter is missing
   *   </li>
   *   <li> PERMISSION_DENIED "Resource" - private resource, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Resource.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  Types.ResourceAttributes getResourceAttributes(1: string authenticationToken,
                                                 2: Types.Guid guid)
  	throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException,
            3: Errors.EDAMNotFoundException notFoundException),

  /**
   * @deprecated -
   *   This function is deprecated, and should no longer be used.  This will
   *   always return a value of '0'.
   */                                                 
  i64 getAccountSize(1: string authenticationToken)
  	throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * Clients should make this call once per day to receive a bundle of ads that
   * will be displayed for the subsequent 24 hour period.
   *
   * @param adParameters
   *   A set of parameters that help the service determine which ads to return.
   */
  list<Types.Ad> getAds(1: string authenticationToken,
                        2: AdParameters adParameters)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),

  /**
   * A thin client should make this call to retrieve a single random ad for
   * immediate display.
   *
   * @param adParameters
   *   A set of parameters to help the service determine which ad to return.
   *   The 'impression' field should either be absent (if no ads have been
   *   displayed previously), or else it should contain the identifier for
   *   the most recently-displayed ad so that the service can give a different
   *   ad.
   */
  Types.Ad getRandomAd(1: string authenticationToken,
                        2: AdParameters adParameters)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMSystemException systemException),


  /**
   * Looks for a user account with the provided userId on this NoteStore
   * shard and determines whether that account contains a public notebook
   * with the given URI.  If the account is not found, or no public notebook
   * exists with this URI, this will throw an EDAMNotFoundException,
   * otherwise this will return the information for that Notebook.
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Publishing.uri" - not found, by URI
   *   </li>
   * </ul>
   */
  Types.Notebook getPublicNotebook(1: Types.UserID userId,
                                   2: string publicUri)
  	throws (1: Errors.EDAMSystemException systemException,
            2: Errors.EDAMNotFoundException notFoundException),


  /**
   * Used to construct a shared notebook object. The constructed notebook will 
   * contain a "share key" which serve as a unique identifer and access token
   * for a user to access the notebook of the shared notebook owner.
   *
   * @param sharedNotebook
   *   An shared notebook object populated with the email address of the share 
   *   recipient, the notebook guid and the access permissions. All other
   *   attributes of the shared object are ignored.
   * @return
   *   The fully populated SharedNotebook object including the server assigned 
   *   share id and shareKey which can both the used to uniquely identify the 
   *   SharedNotebook.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "SharedNotebook.email" - if the  email was not valid
   *   </li>
   *   </ul>
   * @throws EDAMNotFoundException <ul>
   *   <li> Notebook.guid - if the notebookGuid is not a valid guid for the user
   *   </li>
   *   </ul>
   */
  Types.SharedNotebook createSharedNotebook(1: string authenticationToken,
                                        2: Types.SharedNotebook sharedNotebook)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMNotFoundException notFoundException,
            3: Errors.EDAMSystemException systemException),

  /**
   * Lists the collection of shared notebooks for all notebooks in the 
   * users account.
   * 
   * @return 
   *  The list of all SharedNotebooks for the user
   */
  list<Types.SharedNotebook> listSharedNotebooks(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMNotFoundException notFoundException,
            3: Errors.EDAMSystemException systemException),

  /**
   * Expunges the SharedNotebooks in the user's account using the 
   * SharedNotebook.id as the identifier.
   * @param
   *   sharedNotebookIds - a list of ShardNotebook.id longs identifying the
   *       objects to delete permanently.
   * @return 
   *   The account's update sequence number.
   */
  i32 expungeSharedNotebooks(1: string authenticationToken, 
                             2: list<i64> sharedNotebookIds)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMNotFoundException notFoundException,
            3: Errors.EDAMSystemException systemException),
            
  /**
   * Asks the service to make a linked notebook with the provided name, username 
   * of the owner and identifiers provided. A linked notebook can be either a 
   * link to a public notebook or to a private shared notebook.
   *
   * @param linkedNotebook
   *   The desired fields for the linked notebook must be provided on this
   *   object.  The name of the linked notebook must be set. Either a username 
   *   uri or a shard id and share key must be provided otherwise a 
   *   EDAMUserException is thrown.
   *
   * @return
   *   The newly created LinkedNotebook.  The server-side id will be
   *   saved in this object's 'id' field.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "LinkedNotebook.name" - invalid length or pattern
   *   </li>
   *   <li> BAD_DATA_FORMAT "LinkedNotebook.username" - bad username format
   *   </li>
   *   <li> BAD_DATA_FORMAT "LinkedNotebook.uri" -
   *     if public notebook set but bad uri
   *   </li>
   *   <li> BAD_DATA_FORMAT "LinkedNotebook.shareKey" -
   *     if private notebook set but bad shareKey
   *   </li>
   *   <li> DATA_REQUIRED "LinkedNotebook.shardId" - 
   *     if private notebook but shard id not provided
   *   </li>
   * </ul>
   */   
  Types.LinkedNotebook createLinkedNotebook(1: string authenticationToken,
                                       2: Types.LinkedNotebook linkedNotebook)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMNotFoundException notFoundException,
            3: Errors.EDAMSystemException systemException),

  /**
   * @param linkedNotebook
   *   Updates the name of a linked notebook.
   *
   * @throws EDAMUserException <ul>
   *   <li> BAD_DATA_FORMAT "LinkedNotebook.name" - invalid length or pattern
   *   </li>
   * </ul>
   */
  Types.LinkedNotebook updateLinkedNotebook(1: string authenticationToken,
                                       2: Types.LinkedNotebook linkedNotebook)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMNotFoundException notFoundException,
            3: Errors.EDAMSystemException systemException),

  /**
   * Returns a list of linked notebooks
   */            
  list<Types.LinkedNotebook> listLinkedNotebooks(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMNotFoundException notFoundException,
            3: Errors.EDAMSystemException systemException),
            
  /**
   * Permanently expunges the linked notebook from the account. 
   *
   * @param linkedNotebookId
   *   The LinkedNotebook.id field of the LinkedNotebook to permanently remove
   *   from the account.
   */
  i32 expungeLinkedNotebook(1: string authenticationToken,
                            2: i64 linkedNotebookId)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMNotFoundException notFoundException,
            3: Errors.EDAMSystemException systemException),

  /**
   * Asks the service to produce an authentication token that can be used to
   * access the contents of a shared notebook from someone else's account.
   * This authenticationToken can be used with the various other NoteStore
   * calls to find and retrieve notes, and if the permissions in the shared
   * notebook are sufficient, to make changes to the contents of the notebook.
   *
   * @param shareKey
   *   The 'shareKey' identifier from the SharedNotebook that was granted to
   *   some recipient.  This string internally encodes the notebook identifier
   *   and a security signature.
   *
   * @param authenticationToken
   *   If a non-empty string is provided, this is the full user-based
   *   authentication token that identifies the user who is currently logged in
   *   and trying to access the shared notebook.  This may be required if the
   *   notebook was created with 'requireLogin'.
   *   If this string is empty, the service will attempt to authenticate to the
   *   shared notebook without any logged in user.
   *
   * @throws EDAMSystemException <ul>
   *   <li> BAD_DATA_FORMAT "shareKey" - invalid shareKey string
   *   </li>
   *   <li> INVALID_AUTH "shareKey" - bad signature on shareKey string
   *   </li>
   *   <li> SHARD_UNAVAILABLE - Request went to the wrong shard
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "SharedNotebook.id" - the shared notebook no longer exists
   *   </li>
   * </ul>
   *
   * @throws EDAMUserException <ul>
   *   <li> DATA_REQUIRED "authenticationToken" - the share requires login, and
   *          no valid authentication token was provided.
   *   </li>
   *   <li> PERMISSION_DENIED "SharedNotebook.username" - share requires login,
   *          and another username has already been bound to this notebook.
   *   </li>
   * </ul>
   */
  UserStore.AuthenticationResult
    authenticateToSharedNotebook(1: string shareKey,
                                 2: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMNotFoundException notFoundException,
            3: Errors.EDAMSystemException systemException),

  /**
   * This function is used to retrieve extended information about a shared
   * notebook by a guest who has already authenticated to access that notebook.
   * This requires an 'authenticationToken' parameter which should be the
   * resut of a call to authenticateToSharedNotebook(...).
   * I.e. this is the token that gives access to the particular shared notebook
   * in someone else's account -- it's not the authenticationToken for the
   * owner of the notebook itself.
   *
   * @param authenticationToken
   *   Should be the authentication token retrieved from the reply of
   *   authenticateToSharedNotebook(), proving access to a particular shared
   *   notebook.
   * 
   * @throws EDAMUserException <ul>
   *   <li> PERMISSION_DENIED "authenticationToken" -
   *          authentication token doesn't correspond to a valid shared notebook
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "SharedNotebook.id" - the shared notebook no longer exists
   *   </li>
   * </ul>
   */
  Types.SharedNotebook getSharedNotebookByAuth(1: string authenticationToken)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMNotFoundException notFoundException,
            3: Errors.EDAMSystemException systemException),

  /**
   * Attempts to send a single note to one or more email recipients.
   *
   * @param authenticationToken
   *    The note will be sent as the user logged in via this token, using that
   *    user's registered email address.  If the authenticated user doesn't
   *    have permission to read that note, the emailing will fail.
   *
   * @param parameters
   *    The note must be specified either by GUID (in which case it will be
   *    sent using the existing data in the service), or else the full Note
   *    must be passed to this call.  This also specifies the additional
   *    email fields that will be used in the email.
   *
   * @throws EDAMUserException <ul>
   *   <li> LIMIT_REACHED "NoteEmailParameters.toAddresses" -
   *     The email can't be sent because this would exceed the user's daily
   *     email limit.
   *   </li>
   *   <li> BAD_DATA_FORMAT "(email address)" -
   *     email address malformed
   *   </li>
   *   <li> DATA_REQUIRED "NoteEmailParameters.toAddresses" -
   *     if there are no To: or Cc: addresses provided.
   *   </li>
   *   <li> DATA_REQUIRED "NoteEmailParameters.note" -
   *     if no guid or note provided
   *   </li>
   *   <li> PERMISSION_DENIED "Note" - private note, user doesn't own
   *   </li>
   * </ul>
   *
   * @throws EDAMNotFoundException <ul>
   *   <li> "Note.guid" - not found, by GUID
   *   </li>
   * </ul>
   */
  void emailNote(1: string authenticationToken,
                 2: NoteEmailParameters parameters)
    throws (1: Errors.EDAMUserException userException,
            2: Errors.EDAMNotFoundException notFoundException,
            3: Errors.EDAMSystemException systemException)

}

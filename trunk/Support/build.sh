#!/bin/sh

#####
#
# This script takes an optional argument indicating the path to the base Developer directory
#
#####

# Setup variables
DATE=`date "+%Y-%m-%d-%H%M%S"`
SCRATCH_DIR="/tmp/$DATE"
PROJECT="PolActions"
NAME=`echo "$PROJECT" | tr '[A-Z]' '[a-z]'`
XCODEBUILD="$1/usr/bin/xcodebuild"

# Create scratch directory
mkdir "$SCRATCH_DIR"
cd "$SCRATCH_DIR"

# Check out TOT & retrieve version / revision
echo "Checking out HEAD..."
svn checkout "https://$NAME.googlecode.com/svn/trunk/" "$PROJECT" > /dev/null
if [[ $? -ne 0 ]]
then
	rm -rf "$SCRATCH_DIR"
	exit 1;
fi
REVISION=`svn info "$PROJECT" | grep "Revision:" | awk '{ print $2 }'`
VERSION=`svn propget version "$PROJECT/$PROJECT.xcodeproj/project.pbxproj"`
echo "<Using version $VERSION ($REVISION)>"

# Tag revision on server side
echo "Tagging revision on server..."
svn copy -r $REVISION -m "Tagging version $VERSION for revision $REVISION" "https://$NAME.googlecode.com/svn/trunk/" "https://$NAME.googlecode.com/svn/tags/Version-$VERSION-$REVISION" > /dev/null
if [[ $? -ne 0 ]]
then
	rm -rf "$SCRATCH_DIR"
	exit 1;
fi

# Fix svn:externals revisions for PolKit & Thrift on the tagged revision
echo "Fixing external revisions on tagged revision..."
TAG="$PROJECT Tag $VERSION ($REVISION)"
svn checkout "https://$NAME.googlecode.com/svn/tags/Version-$VERSION-$REVISION" "$TAG" > /dev/null
if [[ $? -ne 0 ]]
then
	rm -rf "$SCRATCH_DIR"
	exit 1;
fi
EXTERNAL_REVISION_1=`svn info "$PROJECT/PolKit" | grep "Revision:" | awk '{ print $2 }'`
EXTERNAL_REVISION_2=`svn info "$PROJECT/thrift-cocoa" | grep "Revision:" | awk '{ print $2 }'`
svn propset "svn:externals" "PolKit -r $EXTERNAL_REVISION_1 http://polkit.googlecode.com/svn/trunk/
thrift-cocoa -r $EXTERNAL_REVISION_2 http://svn.apache.org/repos/asf/incubator/thrift/trunk/lib/cocoa" "$TAG" > /dev/null
if [[ $? -ne 0 ]]
then
	rm -rf "$SCRATCH_DIR"
	exit 1;
fi
svn commit -m "Fixed svn:externals" "$TAG" > /dev/null
if [[ $? -ne 0 ]]
then
	rm -rf "$SCRATCH_DIR"
	exit 1;
fi

# Build project
echo "Building project..."
ROOT="$PROJECT $VERSION"
cd "$PROJECT"
$XCODEBUILD install DSTROOT="$SCRATCH_DIR/$ROOT" -nodistribute > /dev/null
cd ..
if [[ $? -ne 0 ]]
then
	rm -rf "$SCRATCH_DIR"
	exit 1;
fi

# Create & upload build archive
ARCHIVE="$PROJECT-$VERSION.zip"
ditto -c -k --keepParent "$ROOT" "$ARCHIVE"
$PROJECT/Support/googlecode_upload.py -s "$PROJECT $VERSION (PRE-RELEASE - DOWNLOAD AT YOUR OWN RISK - DO NOT REDISTRIBUTE)" -l "Type-Archive, OpSys-OSX" -p "$NAME" -u "info@pol-online.net" "$ARCHIVE"
if [[ $? -ne 0 ]]
then
        mv -f "$ARCHIVE" ~/Desktop/
fi

# Delete scratch directory
rm -rf "$SCRATCH_DIR"

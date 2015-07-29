#!/usr/bin/env perl

use strict;
use warnings;
use Data::Printer;
use File::Basename;
use DBI;

my $file_name;
my $file_path;
my $SHA2;
my %hash_sha;
my %hash_file;


my $dbh = DBI->connect ('dbi:mysql:sequences_dtb','root','2hest9hu') or die "Connection Error: $DBI::errstr\n";

my $list  = shift;

open ( my $fh, '<', $list ) || die "Cannot open the file!\n";

while ( my $line = <$fh> ){
	chomp $line;
	
	if ( $line =~ m/(\w{64})\s(.*)/i ){
	
		$SHA2 = $1;
		$file_name = fileparse("$2");
		$file_path = dirname("$2");

		push @{ $hash_sha{ $SHA2 }->{ $file_name } }, $file_path;
		
		
		$hash_file{$file_name}->{'SHA2'} = $SHA2; 
		push @{ $hash_file{$file_name}->{'Path'} } , $file_path;
		
	}


}


foreach my $key_file ( sort { $a cmp $b }  keys %hash_file ) {


	my $sql = " UPDATE Library, File
		    SET SHA2='$hash_file{$key_file}->{'SHA2'}'  
		    WHERE Library.library_id=File.Library_library_id AND File.file_name=".$dbh->quote($key_file);
	my $sth = $dbh->prepare($sql);
	$sth->execute or die "SQL Error: $DBI::errstr\n";
}

# access each SHA2 key, $key_sha = SHA2
foreach my $key_sha ( sort { $a cmp $b } keys %hash_sha ) {

	#check if SHA2 key already exists
	my $select = "SELECT * FROM Library WHERE SHA2 ='$key_sha'" ;
	my $key_sha_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } );

	#if does not exists, insert SHA2 key, path and filename
	if  ( scalar @{$key_sha_row_ref} == 0 ) {
		my $sql = "INSERT INTO Library (SHA2) VALUES ('$key_sha')";
		my $sth = $dbh->prepare($sql);
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		my $library_id = $dbh->last_insert_id(undef, undef, undef, undef);
	
	
		#access each filename key, $sub_key = filename
		foreach my $sub_key ( sort { $a cmp $b } keys %{ $hash_sha{$key_sha} } ) { 
		
			#access each path directory, $element = file path
			foreach my $element ( @{ $hash_sha{$key_sha}->{$sub_key} } ) {

				$sql = "INSERT INTO File (file_name, file_path, Library_library_id) VALUES (" .  $dbh->quote($sub_key) . "," . $dbh->quote($element) . "," . $library_id . ")";
				$sth = $dbh->prepare($sql);
				$sth->execute or die "SQL Error: $DBI::errstr\n";
			}
		}	
	}


	else {

	
		#access each filename key, $sub_key = filename
		foreach my $sub_key ( sort { $a cmp $b } keys %{ $hash_sha{$key_sha} } ) { 
		
			my $select = "SELECT * 
				      FROM Library
				      INNER JOIN File
				      ON Library.library_id=File.Library_library_id
				      WHERE SHA2='$key_sha' AND file_name=" . $dbh->quote($sub_key);
			my $sub_key_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } );
			my $library_id = $sub_key_row_ref->[0]->{'Library_library_id'};	
			my $file_id = $sub_key_row_ref->[0]->{'file_id'};
			
			foreach my $element ( @{ $hash_sha{$key_sha}->{$sub_key} } ) {
			
				#check if path already exists
				$select = "SELECT * FROM File WHERE file_path ='$element' AND Library_library_id='$library_id'" ;
				my $element_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } );
				
				
				#if does not exists, insert new path
				if  ( scalar @{$element_row_ref} == 0 ) {
			 		
					$select = "SELECT * FROM File WHERE file_path IS NULL AND Library_library_id='$library_id'";
					my $path_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } );
					
					if ( scalar @{$path_row_ref} > 0 ) { 
					
						my $sql = "UPDATE File
                         				   SET file_path='$element'
						   	   WHERE File.Library_library_id='$library_id' AND File.file_name=".$dbh->quote($sub_key);
						my $sth = $dbh->prepare($sql);
						$sth->execute or die "SQL Error: $DBI::errstr\n";
					}

					else { 

						my $sql = "INSERT INTO File (file_name, file_path, Library_library_id) VALUES (" .  $dbh->quote($sub_key) . "," . $dbh->quote($element) . "," . $library_id . ")";
						my $sth = $dbh->prepare($sql);
						$sth->execute or die "SQL Error: $DBI::errstr\n";
					}
					
				}
			}
		}
	}
}

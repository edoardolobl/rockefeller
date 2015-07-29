#!/usr/bin/env perl

use strict;
use warnings;
use DBI;
use Data::Printer;



#===================Parse File==================


my @array_final;
my @array_header;
my @array_values;

my $list = shift;

open (my $fh,'<', $list ) || die "Cannot open the file!\n";

while ( my $line = <$fh> ){
	chomp $line;
	next if $line =~ /^\s*$/;		
	
	if ( $line =~ m/^#/ ){
		@array_header = split("\t", $line);
		next;
	}
	
	else {
	
		@array_values = split("\t", $line);
	}
	
	my %hash_aux;
	foreach my $key (0 .. $#array_header ) {
		$hash_aux{ $array_header[$key] } = $array_values[$key] if $array_values[$key];
	}

	push @array_final, \%hash_aux;

}

close ($fh);

#==============Insert DataBase=================


my $dbh = DBI->connect ('dbi:mysql:sequences_dtb','root','2hest9hu') or die "Connection Error: $DBI::errstr\n";

my $id1;
my $id2;


foreach my $element (@array_final){

my $cell_id;
my $method_id;
my $experiment_id;
my $antibody_id;
my $background_id;
my $organism_id;
my $sequencer_id;
my $tissue_id;


	if ( $element->{'Cell'} ){
		my $select = "SELECT * FROM Cell WHERE cell_name = " . $dbh->quote($element->{'Cell'}) ; 
		my $cell_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } );
		
		unless ( scalar @{$cell_row_ref}  > 0 ) { 
			my $sql = "INSERT  INTO Cell (cell_name) VALUES(" . $dbh->quote($element->{'Cell'}) . ")";
			my $sth = $dbh->prepare($sql);
			$sth->execute or die "SQL Error: $DBI::errstr\n";
			$cell_id = $dbh->last_insert_id(undef, undef, undef, undef);
		}

		else {
			$cell_id = $cell_row_ref->[0]->{'cell_id'} ;
		}
	}

	if ( $element->{'Method'} ){
		my $select = "SELECT * FROM Method WHERE method_name = " . $dbh->quote($element->{'Method'}) ; 
		my $method_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } ); 
		
		unless ( scalar @{$method_row_ref} > 0 ) { 
			my $sql = "INSERT INTO Method (method_name) VALUES (" . $dbh->quote($element->{'Method'}) . ")";
			my $sth = $dbh->prepare($sql);
			$sth->execute or die "SQL Error: $DBI::errstr\n";
			$method_id = $dbh->last_insert_id(undef, undef, undef, undef);
		}

		else {
			$method_id = $method_row_ref->[0]->{'method_id'} ;
		}
	}

	if ( $element->{'Experiment'} ){
		my $select = "SELECT * FROM Experiment WHERE experiment_name = " . $dbh->quote($element->{'Experiment'}) ; 
		my $experiment_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } ); 
		
		unless ( scalar @{$experiment_row_ref} > 0 ) { 
			my $sql = "INSERT INTO Experiment (experiment_name) VALUES (" . $dbh->quote($element->{'Experiment'}) . ")";
			my $sth = $dbh->prepare($sql);
			$sth->execute or die "SQL Error: $DBI::errstr\n";
			$experiment_id = $dbh->last_insert_id(undef, undef, undef, undef);
		}
		
		else {
			$experiment_id = $experiment_row_ref->[0]->{'experiment_id'} ;
		}
	}

	if ( $element->{'Antibody'} ){
		my $select = "SELECT * FROM Antibody WHERE antibody_name = " . $dbh->quote($element->{'Antibody'}) ; 
		my $antibody_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } ); 
	
		unless ( scalar @{$antibody_row_ref}  > 0 ) { 
			my $sql = "INSERT  INTO Antibody (antibody_name) VALUES (" . $dbh->quote($element->{'Antibody'}) . ")";
			my $sth = $dbh->prepare($sql);
			$sth->execute or die "SQL Error: $DBI::errstr\n";
			$antibody_id = $dbh->last_insert_id(undef, undef, undef, undef);
		}
	
		else {
			$antibody_id = $antibody_row_ref->[0]->{'antibody_id'} ;
		}
	}
	
	if ( $element->{'Background'} ){	
		my $select = "SELECT * FROM Background WHERE background_name = " . $dbh->quote($element->{'Background'}) ; 
		my $background_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } ); 

		unless ( scalar @{$background_row_ref} > 0 ) { 
			my $sql = "INSERT INTO Background (background_name) VALUES (" . $dbh->quote($element->{'Background'}) . ")";
			my $sth = $dbh->prepare($sql);
			$sth->execute or die "SQL Error: $DBI::errstr\n";
			$background_id = $dbh->last_insert_id(undef, undef, undef, undef);
		}
	
		else {
			$background_id = $background_row_ref->[0]->{'background_id'} ;
		}
	}
	
	if ( $element->{'#Organism'} ){
		my $select = "SELECT * FROM Organism WHERE organism_name = ". $dbh->quote($element->{'#Organism'}) ; 
		my $organism_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } ); 
	
		unless ( scalar @{$organism_row_ref} > 0 ) { 
			my $sql = "INSERT INTO Organism (organism_name) VALUES (" . $dbh->quote($element->{'#Organism'}) . ")";
			my $sth = $dbh->prepare($sql);
			$sth->execute or die "SQL Error: $DBI::errstr\n";
			$organism_id = $dbh->last_insert_id(undef, undef, undef, undef);
		}
		
		else {
			$organism_id = $organism_row_ref->[0]->{'organism_id'} ; 
		}
	}

	if ( $element->{'Sequencer'} ){
		my $select = "SELECT * FROM Sequencer WHERE sequencer_name = " . $dbh->quote($element->{'Sequencer'}) ; 
		my $sequencer_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } ); 
		
		unless ( scalar @{$sequencer_row_ref}  > 0 ) { 
			my $sql = "INSERT  INTO Sequencer (sequencer_name) VALUES (" . $dbh->quote($element->{'Sequencer'}) . ")";
			my $sth = $dbh->prepare($sql);
			$sth->execute or die "SQL Error: $DBI::errstr\n";
			$sequencer_id = $dbh->last_insert_id(undef, undef, undef, undef);
		}

		else {
			$sequencer_id = $sequencer_row_ref->[0]->{'sequencer_id'} ; 
		}		
	}

	if ( $element->{'Tissue'} ){
		my $select = "SELECT * FROM Tissue WHERE tissue_name = " . $dbh->quote($element->{'Tissue'}) ; 
		my $tissue_row_ref = $dbh->selectall_arrayref($select, { Slice => {} } ); 
		
		unless ( scalar @{$tissue_row_ref} > 0 ) { 
			my $sql = "INSERT INTO Tissue (tissue_name) VALUES (" . $dbh->quote($element->{'Tissue'}) . ")";
			my $sth = $dbh->prepare($sql);
			$sth->execute or die "SQL Error: $DBI::errstr\n";
			$tissue_id = $dbh->last_insert_id(undef, undef, undef, undef);
		}
	
		else {
			$tissue_id = $tissue_row_ref->[0]->{'tissue_id'};
		}
	}

#============Start Libray HERE========

	my @array_column;
	my @array_values;
	my @array_read;
	my @array_file_values;
	my @array_file_column;

	if ($organism_id) { 
		push @array_values, $organism_id;
		push @array_column, "Organism_organism_id";		
	}

	if ($tissue_id) {
		push @array_values, $tissue_id;
		push @array_column, "Tissue_tissue_id";
	}
	
	if ($cell_id) { 
		push @array_values, $cell_id;
		push @array_column, "Cell_cell_id";
	}
	
	if ($experiment_id) {
		push @array_values, $experiment_id;
		push @array_column, "Experiment_experiment_id";
	}
	
	if ($method_id) {
		push @array_values, $method_id;
		push @array_column, "Method_method_id";
	}

	if ($sequencer_id) {
		push @array_values, $sequencer_id;
		push @array_column, "Sequencer_sequencer_id";
	}
	
	if ($background_id) {
		push @array_values, $background_id;
		push @array_column, "Background_background_id";
	}
	
	if ($antibody_id) {
		push @array_values, $antibody_id;
		push @array_column, "Antibody_antibody_id";
	}

	if ($element->{'Repeat'}) {
		if ($element->{'Repeat'} =~ m/(.*?)(\d+)$/i ){
			my $var = $1;
			my $repeat_number = $2;

			if ( $var =~ m/^repeat/i){
				push @array_values, $repeat_number; 
				push @array_column, "repeat_id";
			}	
		
			if ( $var =~ m/^replicate/i) {
				push @array_values, $repeat_number;
				push @array_column, "replicate_id";
			}

			if ( $var =~ m/^tecnical/i) {
				push @array_values, "1";
				push @array_column, "repeat_id"
			}
		}
	}




	my $column = join ("," , @array_column);
	my $values = join ("," , @array_values);

	
	my $sql = "INSERT INTO Library ( $column ) VALUES ( $values )";
	my $sth = $dbh->prepare($sql);
	$sth->execute or die "SQL Error: $DBI::errstr\n";
	my $file_lib_id = $dbh->last_insert_id(undef, undef, undef, undef);
#====================File Table================
	
	if ($element->{'Read Type'}) {
		if ($element->{'Read Type'} =~ m/^(paired.*)(1)/i){
			$id1 = $file_lib_id;		
		}
		if ($element->{'Read Type'} =~ m/^(paired.*)(2)/i){
			$id2 = $file_lib_id;			
		} 

	}

	if ($id1 && $id2){
		$sql = "INSERT INTO Read_Type (Library_library_id, Library_library_id1) VALUES ( $id1, $id2)";
		$sth = $dbh->prepare($sql);
		$sth->execute or die "SQL Error: $DBI::errstr\n";
		$id1 = undef;
		$id2 = undef;
	}		

	push @array_file_values, $file_lib_id;
	push @array_file_column, "Library_library_id";
	push @array_file_values, $element->{"Library"};
	push @array_file_column, "file_name";

	my $file_column = join ("," , @array_file_column);
	my $file_values = join ("','" , @array_file_values);

	

	$sql = "INSERT INTO File ( $file_column ) VALUES ('$file_values')";
	$sth = $dbh->prepare($sql);
	$sth->execute or die "SQL Error: $DBI::errstr\n";




}

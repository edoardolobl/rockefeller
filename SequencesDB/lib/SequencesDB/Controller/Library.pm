package SequencesDB::Controller::Library;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

SequencesDB::Controller::Library - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut



sub search :Path('/search') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
	template => 'library/form_search.tt2',
    );
}

sub result_list :Path('/result') :Args(0) {
    my ( $self, $c ) = @_;
    my $rs;
    my $n_entries_per_page = $c->req->param('entries_per_page');
    $n_entries_per_page = 10 unless $n_entries_per_page;
    my $field_value = $c->req->param( 'field_value' );
    my $advanced_search = $c->req->param( 'advanced_search' );
    my $search_options = $c->req->param( 'search_options' );
    my $page_number = $c->req->param( 'page' );
    $page_number = 1 unless $page_number;
    if ($field_value && $advanced_search) {	
    	$rs = $c->model('DB::Library')->search_library( $field_value , $advanced_search , $search_options );
    }
	
    elsif ($field_value	&& !$advanced_search) {
	$c->stash(
		field_value => $field_value, 
		error15 => "Select a search filter!");
	$c->go('search');
    } 

    else {
    	$rs = $c->model('DB::Library')->search_library();
    }
	

    $rs = $rs->search(undef,
		      { 
			page => $page_number,
			rows => $n_entries_per_page,
    		      },
    );
    
	
    $c->stash( 
		rs => $rs,
		template => 'library/result_list.tt2',
	 );    
    
}


sub create_new :Path('/new') :Args(0) {
	my ( $self, $c ) = @_;


	$c->stash(
	    template => 'library/form_new.tt2',
	);
}

sub process_request :Path('/new/library') :Args(0) {
	my ($self, $c ) = @_;

	$c->stash(
	    template => 'library/form_new.tt2',
	);

	my $error = 0;
	my $organism;
	my $tissue;
	my $cell;
	my $experiment;
	my $background;
	my $method;
	my $antibody;
	my $sequencer;
	my $success;

	my $filename = $c->req->param('filename');
	if (!$filename) {
		$c->stash( error1 => "Insert filename!" );
		$error ++;
	}

	my $file_id = $c->req->param('file_id');
	
	my $sha2 = $c->req->param('sha2');
	if (!$sha2) {
		$c->stash( error2 => "Insert a SHA2 key!" );
		$error ++;	
	}

	my $path = $c->req->param('path');
	if (!$path) {
		$c->stash( error3 => "Insert file path!" );
		$error ++;
	}

	my $organism_id = $c->req->param('organism');
	if (!$organism_id) {
		$organism = $c->req->param('input_organism');
		
		if (!$organism) {
			$c->stash( error4 => "Select or insert a new organism!" );
			$error ++;
		}
	}
	
	my $tissue_id = $c->req->param('tissue');
	if (!$tissue_id) {
		$tissue = $c->req->param('input_tissue');
		
		if (!$tissue){
			$c->stash( error5 => "Select or insert a new tissue!" );
			$error ++;
		}
	}

	my $cell_id = $c->req->param('cell');
	if (!$cell_id) {
		$cell = $c->req->param('input_cell');

		if(!$cell) {
			$c->stash( error6 => "Select or insert a new cell!" );
			$error ++;
		}
	}

	my $experiment_id = $c->req->param('experiment');
	if (!$experiment_id) {
		$experiment = $c->req->param('input_experiment');
		
		if (!$experiment) {
			$c->stash( error7 => "Select or insert a new experiment!" );
			$error ++;
		}
	}
	
	my $background_id = $c->req->param('background');
	if (!$background_id) {
		my $background = $c->req->param('input_background');
		
		if (!$background) {
			$c->stash( error8 => "Select or insert a new background!" );
			$error ++;
		}
	}

	my $method_id = $c->req->param('method');
	if (!$method_id) {
		my $method = $c->req->param('input_method');

		if (!$method) {		
			$c->stash( error9 => "Select or insert a new method!" );
			$error ++;
		}
	}

	my $antibody_id = $c->req->param('antibody');
	if (!$antibody_id) {
		$antibody = $c->req->param('input_antibody');

	}

	my $sequencer_id = $c->req->param('sequencer');
	if (!$sequencer_id) {
		my $sequencer = $c->req->param('input_sequencer');

		if (!$sequencer) {
			$c->stash( error11 => "Select or insert a new sequencer!" );
			$error ++;
		}
	}

	my $repeat = $c->req->param('repeat');
	if ( (! defined $repeat) || ( $repeat !~ /^\d+$/)  ) {
		$c->stash( error12 => "Insert the repeat number!" );
		$error ++;
	}

	my $replicate = $c->req->param('replicate');
	if ( (! defined $replicate) || ($repeat !~ /^\d+$/)  ) {
		$c->stash( error13 => "Insert the replicate number!" );
		$error ++;
	}

	$c->stash(
		filename	=> $filename,
		sha2		=> $sha2,
		path		=> $path,
		organism_id	=> $organism_id,
		organism	=> $organism,
		tissue_id	=> $tissue_id, 
		tissue		=> $tissue,
		cell_id		=> $cell_id,
		cell		=> $cell,
		experiment_id	=> $experiment_id,
		experiment	=> $experiment,
		background_id	=> $background_id,
		background	=> $background,
		method_id	=> $method_id,
		method		=> $method,
		antibody_id	=> $antibody_id,
		antibody	=> $antibody,
		sequencer_id	=> $sequencer_id,
		sequencer	=> $sequencer,
		repeat		=> $repeat,
		replicate	=> $replicate,		
	);
	

	if ($error) {	
		$c->go('create_new');
	}

	if (!$file_id) {	
		my $sha2_validate = $c->model('DB::Library')->find({ sha2 => $sha2 });
		my $filename_validate = $c->model('DB::File')->find({ file_name => $filename,
								      file_path => $path,
								    });
		if ($filename_validate) {
			$c->stash( error14 => "File " . $filename . " already exists at " . $path );
		}

		elsif ($sha2_validate) {
			$c->stash( 	library_id_validate 	=> $sha2_validate->library_id,
					filename_validate	=> $filename,
					path_validate		=> $path,
						error15			=> "Library ID " . $sha2_validate->library_id . " already exists! SHA-key: " . $sha2_validate->sha2 . " <br><p> Insert file to the current library?</p>" );
	
		}
		return;
	}	
	

	if ($organism) {
		my $organism_aux = $c->model('DB::Organism')->create({
			organism_name => $organism,
		});
		$organism_id = $organism_aux->id;
	}
	
	if ($tissue) {
		my $tissue_aux = $c->model('DB::Tissue')->create({
			tissue_name => $tissue,
		});
		$tissue_id = $tissue_aux->id;
	}
	
	if ($cell) {
		my $cell_aux = $c->model('DB::Cell')->create({
			cell_name => $cell,
		});
		$cell_id = $cell_aux->id;
	}

	if ($experiment) {
		my $experiment_aux = $c->model('DB::Experiment')->create({
			experiment_name => $experiment,
		});
		$experiment_id = $experiment_aux->id;
	}
	
	if ($background) {
		my $background_aux = $c->model('DB::Background')->create({
			background_name => $background,
		});
		$background_id = $background_aux->id;
	}
	
	if ($method) {
		my $method_aux = $c->model('DB::Method')->create({
			method_name => $method,
		});
		$method_id = $method_aux->id;
	}

	if ($antibody) {
		my $antibody_aux = $c->model('DB::Antibody')->create({
			antibody_name => $antibody,
		});
		$antibody_id = $antibody_aux->id;
	}

	if ($sequencer) {
		my $sequencer_aux = $c->model('DB::Sequencer')->create({
			sequencer_name => $sequencer,
		});
		$sequencer_id = $sequencer_aux->id;
	}


	
	if ( !$antibody_id ) {
		$antibody_id = undef;
	}
	
	if ($file_id) {

		my $file = $c->model('DB::File')->find({ file_id => $file_id });
		$file->update({
			file_name => $filename,
			file_path => $path,
		});
		
				
		my $library = $c->model('DB::Library')->find({ library_id => $file->library_library_id });

		if ( $library->sha2 ne $sha2 ) {
			my $sha2_aux = $c->model('DB::Library')->find({ sha2 => $sha2 });
			
			if ($sha2_aux) {
				$c->stash(	 file_id => $file_id,
						 error14 => "Library ID " . $library->id . " already exists! Search for SHA2-key: " . $sha2 . " to obtain file info." );
				return;
			}
				
		}
		$library->update({
			organism_organism_id => $organism_id,
			tissue_tissue_id => $tissue_id,
			cell_cell_id => $cell_id,
			experiment_experiment_id => $experiment_id,
			background_background_id => $background_id,
			method_method_id => $method_id,
			antibody_antibody_id => $antibody_id,
			sequencer_sequencer_id => $sequencer_id,
			repeat_id => $repeat,
			replicate_id => $replicate,
			sha2 => $sha2,
		});

		$success = "Library updated successfully!";	
		
	}
	
	else {

		my $library = $c->model('DB::Library')->create({
			organism_organism_id => $organism_id,
			tissue_tissue_id => $tissue_id,
			cell_cell_id => $cell_id,
			experiment_experiment_id => $experiment_id,
			background_background_id => $background_id,
			method_method_id => $method_id,
			antibody_antibody_id => $antibody_id,
			sequencer_sequencer_id => $sequencer_id,
			repeat_id => $repeat,
			replicate_id => $replicate,
			sha2 => $sha2,
		
		});
		
	
		my $id = $library->id;
	
		my $file = $c->model('DB::File')->create({
			file_name => $filename,
			file_path => $path,
			library_library_id => $id,
		});
	
		$success = "Library created sccessfully!";	
		
	}

	$c->stash(
	    success  => $success,
	);

	if ($success) {
		$c->go('search');
	}

}

sub edit :Path('/edit') :Args(0) {
	my ($self, $c ) = @_;

	my $file_id = $c->req->param('file_id');

	my $rs =  $c->model('DB::Library')->search_library( $file_id, "files_inner.file_id" , "equal" ); 
	my $field = $rs->first;

	my $rs_file = $field->files_inner;
	my $file = $rs_file->first;
		
	$c->stash(
	filename	=> $file->file_name,
	file_id		=> $file_id,
	sha2		=> $field->sha2,
	path		=> $file->file_path,
	organism_id	=> $field->organism_organism_id,
	tissue_id	=> $field->tissue_tissue_id, 
	cell_id		=> $field->cell_cell_id,
	experiment_id	=> $field->experiment_experiment_id,
	background_id	=> $field->background_background_id,
	method_id	=> $field->method_method_id,
	antibody_id	=> $field->antibody_antibody_id,
	sequencer_id	=> $field->sequencer_sequencer_id,
	repeat		=> $field->repeat_id,
	replicate	=> $field->replicate_id,		

	);


	$c->stash(
		file_id  => $file_id,
		template => 'library/form_new.tt2',
	); 
}


sub insert_file :Path('/new/library/insert_file') :Args(0) {
	my ( $self, $c ) = @_;

	my $library_id = $c->req->param('library_id_validate');
	my $filename = $c->req->param('filename_validate');
	my $path = $c->req->param('path_validate');

	my $file = $c->model('DB::File')->create({
		file_name => $filename,
		file_path => $path,
		library_library_id => $library_id,
	});

	my $success = "File created sccessfully!";

	$c->stash(
		success   => $success,
		template  => 'library/form_search.tt2',
	); 
}


 	

=encoding utf8

=head1 AUTHOR

Edoardo,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


=head2 search

=cut


__PACKAGE__->meta->make_immutable;

1;

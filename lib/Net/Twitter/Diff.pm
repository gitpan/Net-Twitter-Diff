package Net::Twitter::Diff;

use warnings;
use strict;
use base qw/Net::Twitter/;
use Array::Diff;

our $VERSION = '0.03';

sub xfollowing {
    my $self = shift;
    my $id   = shift;

      my $url = $self->{apiurl} . "/statuses/friends" ;
      $url .= (defined $id) ? "/$id.json" : ".json";
      $url .= '?page=';
    
    my $page = 1;
    my @data = ();
    while(1){
        my $page_url = $url . $page ;
        my $req = $self->{ua}->get($page_url);

        die 'fail to connect to twitter. maybe over Rate limit exceeded or auth error' unless $req->is_success;
        return [] if $req->content eq 'null';

        my $res = JSON::Any->jsonToObj($req->content) ;

        last unless scalar @{ $res } ;
        push @data , @{ $res } ;


        $page++;
    }

    return \@data;
}

sub xfollowers {
    my $self = shift;
    
    my $page = 1;
    my @data = ();
    while(1){
        my $url = $self->{apiurl} . "/statuses/followers.json?page=$page" ;
        my $req = $self->{ua}->get($url);

        die 'fail to connect to twitter. maybe over Rate limit exceeded or auth error' unless $req->is_success;
        return [] if $req->content eq 'null';

        my $res = JSON::Any->jsonToObj($req->content) ;

        last unless scalar @{ $res } ;
        push @data , @{ $res } ;


        $page++;
    }

    return \@data;
}

sub diff {
    my $self = shift;
    my $args = shift;

    my $res = {};
    my $followings_hash = $self->xfollowing();
    my $followers_hash   = $self->xfollowers();
    my $followers = [];
    my $followings = [];

    for my $item ( @{ $followings_hash } ) {
        push @{ $followings } , $item->{screen_name};
    }

    for my $item ( @{ $followers_hash } ) {
        push @{ $followers } , $item->{screen_name};
    }

    my $diff = Array::Diff->diff( $followers , $followings );

    $res->{not_following} = $diff->deleted; 
    $res->{not_followed}  = $diff->added; 
    my @communicated = ();
    my $not_followed_ref = {};
    for my $user ( @{  $res->{not_followed} } ) {
           $not_followed_ref->{ $user } = 1; 
    }

    for my $screen_name ( @{ $followings } ) {
        if ( !defined $not_followed_ref->{ $screen_name  } ) {
            push @communicated , $screen_name 
        }
    }

    $res->{communicated} = \@communicated;

    return $res;
}


sub comp_following {
    my $self = shift;
    my $id   = shift;

    my $res = {};
    my $me_ref = $self->xfollowing();
    my $him_ref = $self->xfollowing( $id );

    
    my $me  = [];
    my $him = [];
    my $me_hash = {};
    for my $item ( @{ $me_ref } ) {
        push @{ $me } , $item->{screen_name};
        $me_hash->{ $item->{screen_name} } = 1;
    }

    for my $item ( @{ $him_ref } ) {
        push @{ $him } , $item->{screen_name};
    }

    my $diff = Array::Diff->diff( $me , $him );

    $res->{only_me} = $diff->deleted; 
    $res->{not_me}  = $diff->added; 
    my @communicated = ();

    for my $screen_name ( @{ $him } ) {
        if ( defined $me_hash->{ $screen_name  } ) {
            push @communicated , $screen_name 
        }
    }

    $res->{share} = \@communicated;

    return $res;
}

1;

=head1 NAME

Net::Twitter::Diff - Twitter Diff

=head1 SYNOPSYS

    use Net::Twitter::Diff;

    my $diff = Net::Twitter::Diff->new(  username => '******' , password => '******');
    
    my $res = $diff->diff();

    # get screen_names who you are not following but they are.
    print Dumper $res->{not_following};

    # get screen_names who they are not following but you are.
    print Dumper $res->{not_followed};

    # get screen_names who you are following them and also they follow you. 
    print Dumper $res->{communicated}; 


    my $res2 = $diff->comp_following( 'somebody_twitter_name' );

    # only you are following
    print Dumper $res2->{only_me} ;

    # you are not following but somebody_twitter_name are following
    print Dumper $res2->{not_me} ;

    # both you and somebody_twitter_name are following
    print Dumper $res2->{share} ;


    # If you want , this module use Net::Twitter as base so you can use methods Net::Twitter has.
    $diff->update('My current Status');
    
=head1 DESCRIPTION

Handy when you want to know relationshop between your followers and follwoings and when you wnat to compare your following and sombody's.

=head1 METHOD

=head2 diff

run diff

response hash

=over 4

=item B<not_following>

get screen_names who you are not following but they are.

=item B<not_followed>

get screen_names who they are not following but you are.

=item B<communicated>

get screen_names who you are following them and also they follow you. 

=back

=head2 comp_following( $twitter_id )

compaire your following and somebody's

response hash

=over 4

=item B<only_me>

only you are following

=item B<not_me>

you are not following but sombody is following

=item B<share>

both you and somebody are following.

=back

=head2 xfollowing

can get more that 100 followings.

=head2 xfollowers

can get more that 100 followers.

=head1 SEE ALSO

L:<Net::Twitter>

=head1 AUTHOR

Tomohiro Teranishi<tomohiro.teranishi@gmail.com.

=cut

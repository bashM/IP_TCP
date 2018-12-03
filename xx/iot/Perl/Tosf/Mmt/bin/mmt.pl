changecom(`#')

define(mmt_TableBegin,
   `my $self;
   my $mmt_taskName; 
   my $mmt_currentState; 

   sub tick {  
      $self = shift @_;
      $mmt_currentState = shift @_; 
      no warnings "experimental::smartmatch"; '

)

define(mmt_TableRow,
   `if ($mmt_currentState ~~ $1) {
      $2;
      return ($3);
   } '
)

define(mmt_TableEnd,
   `die(Tosf::Exception::Trap->new(name => "Tosf:Mmt  no such state"));
   };'
)

define(mmt_Reset,
  `sub whoami {

      if ($mmt_taskName eq "none") {
         die(Tosf::Exception::Trap->new(name => "Tosf:Mmt  whoami can only be called from reset"));
      }

      return $mmt_taskName;
   }

  sub reset {
      $self = shift @_;
      $mmt_taskName = shift @_; 
      no warnings "experimental::smartmatch";

      $2;
      $mmt_taskName = "none"; 
      return ($1); 
   }; '
)

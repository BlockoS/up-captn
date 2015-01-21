#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my ($input_filename, $output_basename, $start_bank, $org) = @ARGV;
die "Missing vgm input"  unless defined($input_filename);
die "Missing output basename" unless defined($output_basename);
die "Missing start bank" unless defined($start_bank);
die "Missing address" unless defined($org);

my ($gd3_offset, $data_offset, $loop_bank, $loop_offset, $data_size, $bank, $data);

open my $input_handle, "<", $input_filename or die $!;
    binmode($input_handle);

    seek($input_handle, 0x14, 0);
    read($input_handle, $gd3_offset, 4);

    seek($input_handle, 0x1C, 0);
    read($input_handle, $loop_offset, 4);
    
    seek($input_handle, 0x34, 0);
    read($input_handle, $data_offset, 4);
    
    $data_offset = unpack('L', $data_offset);
    $loop_offset = unpack('L', $loop_offset);
    $gd3_offset  = unpack('L', $gd3_offset);
     
    $data_size = $gd3_offset - $data_offset;
    $loop_offset = ($loop_offset + 0x1C) - $data_offset - 0x34;
    $loop_bank = int($loop_offset / 8192) + $start_bank;
    $loop_offset = ($loop_offset & 0x1fff) + hex($org);
    
    seek($input_handle, $data_offset+0x34, 0);

    my $inc_filename = $output_basename.".inc";
    open my $inc_handle, ">", $inc_filename or die $!;
    
    printf $inc_handle sprintf("song_bank = \$$start_bank\nsong_addr = \$$org\nsong_loop_offset = \$%x\nsong_loop_bank = \$%x\n", $loop_offset, $loop_bank);

    for($bank=0;$data_size>0; $data_size-=8192, $bank++)
    {
        my $bank_size = ($data_size >= 8192) ? 8192 : $data_size;
        my $output_filename = $output_basename."_${bank}.bin";
        
        print $inc_handle "    .bank ".($start_bank+$bank)."\n    .org \$${org}\n    .incbin \"${output_filename}\"\n";

        read($input_handle, $data, $bank_size);
        open my $output_handle, ">", $output_filename or die $!;
            binmode($output_handle);
            print $output_handle $data;
        close $output_handle;
    }
    
    close $inc_handle;
close $input_handle;

$data_size = $gd3_offset - $data_offset;
print "$input_filename\n\tvgm data size: ${data_size}\n\tgenerated ${bank} file(s)\n";
printf("loop offset: %x loop bank: %x", $loop_offset, $loop_bank);
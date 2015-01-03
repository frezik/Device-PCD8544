# Copyright (c) 2015  Timm Murray
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
package Device::PCD8544::ConvertImage;

use v5.14;
use warnings;
use Device::PCD8544::Exceptions;

use constant WIDTH  => 84;
use constant HEIGHT => 48;


sub convert
{
    my ($img) = @_;
    my $width = $img->getwidth;
    my $height = $img->getheight;
    if( ($width != WIDTH) || ($height != HEIGHT) ) {
        Device::PCD8544::ImageSizeException->throw( 'Width/height is'
            . " $width/$height"
            . ', expected is ' . WIDTH . '/' . HEIGHT
            . '.  Please rescale image.' );
    }

    my @lcd_bitmap = ();
    
    my $total_pixels = $width * $height;
    my $word = 0x00;
    my $pixels_counted = 0;
    foreach my $x (0 .. ($width-1)) {
        foreach my $y (0 .. ($height-1)) {
            my $pixel = $img->getpixel( x => $x, y => $y )
                or die "Could not get pixel ($x, $y)\n";

            my @channels = $pixel->rgba;
            my $val = $channels[0] ? 0 : 1;

            $word = ($word << 1) | $val;
            $pixels_counted++;

            if( $pixels_counted >= 8 ) {
                push @lcd_bitmap, $word;
                $word           = 0x00;
                $pixels_counted = 0;
            }
        }
    }
    return \@lcd_bitmap;
}


1;
__END__

=head1 NAME

  Device::PCD8544::ConvertImage - Convert an image to the format for the PCD8544 LCD

=cut

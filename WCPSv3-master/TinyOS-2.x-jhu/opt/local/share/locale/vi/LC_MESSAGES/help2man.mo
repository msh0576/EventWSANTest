��    .      �  =   �      �     �       !   &     H     a     z  &   �     �     �  �   �  �   �  �   X  	             !     -     6     B     K     Q     W     ]  "   k  �   �     E     J     R  �   Z  �   	     �	  1   �	     �	     �	     �	  �   
  B   �
  1   .     `  5   y     �     �     �  )   �     �     �  �    $   �     �  4     #   K  )   o  !   �  ;   �  
   �       �       �    �                    '     0  	   @     J  
   P  
   [     f  :   v    �     �     �     �  �   �  �   �     q  8   �  	   �  
   �  #   �  1  �  ]   '  *   �  #   �  h   �     =     I     _  9   m     �     �     %             '   "          ,          (       -              !      $   #   	                                   
                              &                                           )   +          .   *    %s \- manual page for %s %s %s: can't create %s (%s) %s: can't get `%s' info from %s%s %s: can't open `%s' (%s) %s: can't unlink %s (%s) %s: error writing to %s (%s) %s: no valid information found in `%s' AUTHOR AVAILABILITY Additional material may be included in the generated output with the
.B \-\-include
and
.B \-\-opt\-include
options.  The format is simple:

    [section]
    text

    /pattern/
    text
 Any
.B [NAME]
or
.B [SYNOPSIS]
sections appearing in the include file will replace what would have
automatically been produced (although you can still override the
former with
.B --name
if required).
 Blocks of verbatim *roff text are inserted into the output either at
the start of the given
.BI [ section ]
(case insensitive), or after a paragraph matching
.BI / pattern /\fR.
 COPYRIGHT DESCRIPTION ENVIRONMENT EXAMPLES Environment Examples FILES Files Games INCLUDE FILES Include file for help2man man page Lines before the first section or pattern which begin with `\-' are
processed as options.  Anything else is silently ignored and may be
used for comments, RCS keywords and the like.
 NAME OPTIONS Options Other sections are prepended to the automatically produced output for
the standard sections given above, or included at
.I other
(above) in the order they were encountered in the include file.
 Patterns use the Perl regular expression syntax and may be followed by
the
.IR i ,
.I s
or
.I m
modifiers (see
.BR perlre (1)).
 REPORTING BUGS Report +(?:[\w-]+ +)?bugs|Email +bug +reports +to SEE ALSO SYNOPSIS System Administration Utilities The full documentation for
.B %s
is maintained as a Texinfo manual.  If the
.B info
and
.B %s
programs are properly installed at your site, the command
.IP
.B info %s
.PP
should give you access to the complete manual.
 The latest version of this distribution is available on-line from: The section output order (for those included) is: This +is +free +software Try `--no-discard-stderr' if option outputs to stderr Usage User Commands Written +by help2man \- generate a simple manual page or other Project-Id-Version: help2man 1.38.1-pre1
Report-Msgid-Bugs-To: Brendan O'Dea <bug-help2man@gnu.org>
POT-Creation-Date: 2012-01-02 17:44+1100
PO-Revision-Date: 2010-04-13 20:28+0930
Last-Translator: Clytie Siddall <clytie@riverland.net.au>
Language-Team: Vietnamese <vi-VN@googlegroups.com>
Language: vi
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Plural-Forms: nplurals=1; plural=0;
X-Generator: LocFactoryEditor 1.8
 %s \- trang hướng dẫn cho %s %s %s: không thể tạo %s (%s) %s: không thể lấy thông tin « %s » từ %s%s %s: không thể mở « %s » (%s) %s: không thể bỏ liên kết %s (%s) %s:  lỗi ghi nhớ vào %s (%s) %s: không tìm thấy thông tin hợp lệ trong « %s » TÁC GIẢ TÍNH SẴN SÀNG Cũng có thể bao gồm dữ liệu bổ sung trong kết xuất, dùng tuỳ chọn
.B \-\-include
và
.B \-\-opt\-include
Có một định dạng đơn giản:

    [phần]
    chuỗi

    /mẫu/
    chuỗi
 Bắt cứ phần
.B [NAME]
hoặc
.B [SYNOPSIS]
nào xuất hiện trong tập tin bao gồm thì thay thế kết xuất tự động tạo
(dù bạn vẫn còn có dịp ghi đè lên phần [NAME] bằng:
.B --name
nếu cần).

NAME: TÊN
SYNOPSIS: TÓM TẮT
 Khối văn bản định dạng *roff đúng nguyên văn được chèn vào kết xuất
hoặc ở đầu của phần
.BI [ phần ]
(không phân biệt chữ hoa/thường),
hoặc đẳng sau một đoạn văn tương ứng với mẫu
.BI / mẫu /\fR.
 BẢN QUYỀN MÔ TẢ MÔI TRƯỜNG VÍ DỤ Môi +trường Ví +dụ TỆP Tập +tin Trò chơi TỆP BAO GỒM Bao gồm tập tin cho trang hướng dẫn về help2man Dòng nào đẳng trước phần đầu tiên hoặc mẫu bắt đầu với « \- » thì được xử
lý dưới dạng tuỳ chọn. Dữ liệu khác (nếu có) bị bỏ qua mà không xuất chi
tiết, và có thể được sử dụng làm ghi chú, từ khoá RCS v.v.
 TÊN TÙY CHỌN Tuỳ +chọn Các phần khác được thêm vào đầu của kết xuất tự động tạo
cho những phần tiêu chuẩn đưa ra trên, hoặc được bao gồm tại
.I other
(bên trên) theo thứ tự gặp trong tập tin bao gồm.
 Mẫu chấp nhận cú pháp của biểu thức chính quy Perl,
và cũng cho phép dấu sửa đổi
.IR i ,
.I s
hay
.I m
(xem
.BR perlre (1)).
 THÔNG BÁO LỖI Thông +báo +lỗi|Gửi thư +thông +báo +lỗi +cho XEM THÊM TÓM TẮT Tiện ích quản lý hệ thống Tài liệu hướng dẫn đầy đủ về
.B %s
được bảo tồn dưới dạng một sổ tay Texinfo.
Nếu chương trình
.B info
và
.B %s
được cài đặt đúng ở địa chỉ của bạn thì câu lệnh
.IP
.B info %s
.PP
nên cho phép bạn truy cập đến sổ tay hoàn toàn.
 Phiên bản mới nhất của bản phân phối này có sẵn sàng trực tuyến từ : Thứ tự xuất phần (đã bao gồm): Đây +là +phần +mềm +tự +do Nếu tuỳ chọn xuất qua đầu lỗi tiêu chuẩn thì thử lập cờ « --no-discard-stderr » Sử dụng Lệnh người dùng Viết +bởi help2man \- tạo một trang hướng dẫn đơn giản hoặc khác 
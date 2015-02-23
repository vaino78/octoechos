#!/usr/bin/perl

use utf8;

$REMOVE_LANG_COMMAND=1; # удалять или нет <::лат> и т.п.

$REMOVE_PAGE_IDS=1;     # удалять или нет ссылки на стр источника (л. рп~г)
$KEEP_THEM_AS_LABELS=0; # сохранять ли их для ссылок с помощью \label?
                        # это может вставить кое-где ненужные пробелу

$TREAT_DBL_EMPH=1;         # меняем %<%[...%]%> блоки на \cslDemph{...}{...}
$DBL_EMPH_COM = "cslDemph";# \cslDemph потом определим в document class'е

$TREAT_EMPH=1;          # меняем %[...%] блоки на \cslemph{...}
$EMPH_COM = "cslemph";  #

$TREAT_SMALL=1;         # меняем %(...%) блоки на \cslsmall{...}
$SMALL_COM = "cslsmall";#

$TREAT_KINOVAR=1;      # меняем %<...%> блоки на \kinovar{...}

$DETECT_SERVICES=0;    # находим предложения, содержащие "на малей вечерни"
                       # и делаем их особыми командами

$FIX_BREAKS=1;         # вставляем неразрываемые пробелы между сочетаниями 
                       # типа гласъ а~

$/=""; # Обрабатываем текст абзацами

while (<>) {

  s/<>/\n\n/g;  s(_/)(\n\n/)g;  # абзац

  if ($REMOVE_LANG_COMMAND) {
    if ( /^<::лат>/ || /^<::рус>/ || /^<::слав>/ ) {
      next; # игнорируем абзац, который начинается с указания ясыка
    }
  } else { # заменяем  <::слав> на \csl и т.д.
    s/<::лат>/\\civil /g;
    s/<::рус>/\\civil /g;
    s/<::слав>/\\csl /g;
  }

  if ($REMOVE_PAGE_IDS) {
    if ($KEEP_THEM_AS_LABELS) {
      while (/\(л\.\s*(.*?)\)/s) {
	$cont = $1;
	$cont =~ tr/авгдезиклмнопрстуфхцч_~\\/ABGDEZIKLMNOPRSTUFXCWYJ\\V/;
	$cont =~ s/w=б\./ob/;
	s/\(л\.\s*(.*?)\)/{\\civil\\label{$cont}}/s;
      }
    } else {
      s/\(л\.\s*(.*?)\)//gs;
    }
  }

  if ( $FIX_BREAKS ) {
    s/([Гг])ла'съ[\s\n]+([авгдsзи_<])/$1ла'съ<_>$2/sg;
  }

  if ($TREAT_DBL_EMPH) {
    while ( /%<%\[(.*?)%\]\.?%>/s ) {
      $cont = $1;
      $trimmedcont = &civilize($cont);
      s/%<%\[(.*?)%\]\.?%>/\\$DBL_EMPH_COM\{$1\}{$trimmedcont}/s;
    }
  }

   if ($TREAT_EMPH) {
     s/%\[(.*?)%\]/\\$EMPH_COM\{$1\}/sg;
   }

   if ($TREAT_SMALL) {
     s/%\((.*?)%\)/\\$SMALL_COM\{$1\}/sg;
   }

   if ($TREAT_KINOVAR) {
     while (/%<(.*?)%>/s) {
       $cont = $1;
       /%<(.*?)%>(.)/s;
       $end = $2;
       if ( $end =~ /[\s\n]/ ) {
	 s/%<(.*?)%>/\\kinovarsimple{$cont}/s;
       } else {
	 @words = split(' ',$cont);
	 if ( $#words>0 ) { # put each word inside its kinovar command
	   $last = pop @words;
	   $cont = join ('} \\kinovarsimple{',@words);
	   $cont = $cont.'} \kinovar{'.$last;
	   s/%<(.*?)%>(.*?)([\s\n])/\\kinovarsimple{$cont}{$2}$3/s;
	 } else {
	   s/%<(.*?)%>(.*?)([\s\n])/\\kinovar{$cont}{$2}$3/s;
	 }
       }
     }
   }



  if ( $DETECT_SERVICES ) {
    if (
	( /^(\\kinovarsimple{)?[Нн]а\s.*вече'рни[.,]?/ && ! /\[.*вече'рни.*]/ )
	||
	/^(\\kinovarsimple{)?[Нн]а\s.*о_у='трени[.,]?/) {
      chomp;
      $w = &civilize($_);
      $_ = '\service{'.$_.'}{'.$w."}\n";
    }
    s/^\\kinovarsimple{На} \\kinovarsimple{лiтургi'и}/\\servicel{На лiтургi'и}{На лiтургiи}/;
  }

  print;
}

sub civilize{
  my $word=$_[0];
  $word =~ s/[=`'^]//g;
  $word =~ s/д\\с/оспод/g;
  $word =~ s/([Бб])г~/$1ог/g;
  $word =~ s/п~с/пас/g;
  $word =~ s/л~ж/лаж/g;
  $word =~ s/р\\ст/рист/g;
  $word =~ s/п\\сл/постол/g;
  $word =~ s/v\\гл/вангел/g;
  $word =~ s/([Ii])и~с/$1исус/g;
  $word =~ s/v"/и/g;
  $word =~ s/о_у/у/g;
  $word =~ s/О_у/У/g;
  $word =~ s/<_>//g;
  $word =~ s/_//g;
  $word =~ s/([Оо])\\т/$1т/g;
  $word =~ s/~//g;

  $word =~ s/\\cslemph{(.*?)}/$1/sg;
  $word =~ s/\\kinovarsimple{(.*?)}/$1/sg;
  $word =~ s/\\kinovar{(.*?)}{(.*?)}/$1$2/sg;

  return $word;
} 
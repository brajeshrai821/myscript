#!/bin/sh

chmod 750 lib/libons.so
chmod 755 rules/lib/rl.jar rules/lib/rl_dms.jar rules/lib/rulesdk.jar rules/lib/jsr94_obr.jar rules/lib/jr_dav.jar rules/lib/webdavrc.jar rules/fileRepositories/ruleRepository rules/webapps/ruleauthor.ear rules/webapps/rulehelp.ear
chmod 755 bin/removeinstance bin/createinstance bin/ojspc j2ee/home/jsp/bin/ojspc ant/bin/runrc.cmd ant/bin/runant.py ant/bin/runant.pl ant/bin/envset.cmd ant/bin/complete-ant-cmd.pl ant/bin/antenv.cmd ant/bin/antRun.pl ant/bin/antRun ant/bin/ant.cmd ant/bin/ant
chmod 600 j2ee/home/config/oc4jclient.policy j2ee/home/config/mime.types j2ee/home/config/jazn.security.props j2ee/home/config/java2.policy
chmod 775 toplink/bin/tljaxb.sh
chmod 755 bin/runstartupconsole.sh bin/runstartupconsole.bat install/rmdir.sh install/rmdir.bat
chmod 700 diagnostics/bin/printlogs.sbs
chmod 755 lib/dms.jar lib/dmsapp.jar lib/libdms2.so diagnostics/lib/ojdl.jar diagnostics/lib/ojdl2.jar diagnostics/lib/ojdl-log4j.jar
chmod 755 bin/chgtocfmt bin/chgtocfmt.pl jlib/cf_mt.jar
chmod 755 backup_restore/bkp_res_interface.pl backup_restore/bkp_restore.pl backup_restore/bkp_restore.sh
chmod 775 bin/win_touch.exe install/changed_files_list.txt inventory/ContentsXML/oraclehomeproperties.xml config/run_opatch.sh config/run_opatch.bat opatches/p5907304_10105_WINNT.zip
chmod 0755 oui/bin/ouica.sh
chmod 0664 oui/jlib/ewt3.jar oui/jlib/ewt3-nls.jar oui/jlib/jewt4.jar oui/jlib/jewt4-nls.jar oui/jlib/help4.jar oui/jlib/help4-nls.jar oui/jlib/InstHelp.jar oui/jlib/InstImages.jar oui/jlib/oracle_ice.jar oui/jlib/swingaccess.jar oui/jlib/ewt3-swingaccess.jar oui/jlib/classes12.jar oui/jlib/prereq.jar
chmod 0755 diagnostics/config/registration/OUI.xml
chmod 0664 oui/oraparam.ini oui/clusterparam.ini
chmod 0775 oui/bin/lsnodes oui/bin/attachHome.sh oui/bin/runInstaller oui/bin/addNode.sh oui/bin/runInstaller.sh oui/bin/resource/cons.nls oui/bin/resource/cons_de.nls oui/bin/resource/cons_es.nls oui/bin/resource/cons_fr.nls oui/bin/resource/cons_it.nls oui/bin/resource/cons_ja.nls oui/bin/resource/cons_ko.nls oui/bin/resource/cons_pt_BR.nls oui/bin/resource/cons_zh_CN.nls oui/bin/resource/cons_zh_TW.nls
chmod 644 OPatch/perl_modules/Command.pm OPatch/perl_modules/RollBack.pm OPatch/perl_modules/Query.pm OPatch/perl_modules/XML.pm OPatch/perl_modules/Apply.pm OPatch/perl_modules/opatchIO.pm OPatch/perl_modules/AttachHome.pm OPatch/perl_modules/Version.pm OPatch/perl_modules/LsInventory.pm OPatch/jlib/opatch.jar OPatch/docs/FAQ OPatch/docs/bt2.txt OPatch/docs/bt1.txt OPatch/docs/README.txt OPatch/docs/Users_Guide.txt
chmod 755 OPatch/opatch
chmod 644 OPatch/opatch.pl OPatch/opatch.ini
chmod 0664 oui/jlib/xmlparserv2.jar oui/jlib/srvm.jar oui/jlib/OraInstaller.jar oui/jlib/OraInstallerNet.jar oui/jlib/oneclick.jar oui/jlib/share.jar
chmod 0775 oui/lib/linux/libsrvm10.so oui/lib/linux/liboraInstaller.so
chmod 775 jre/1.4.2/bin/java jre/1.4.2/bin/keytool jre/1.4.2/bin/policytool jre/1.4.2/bin/kinit jre/1.4.2/bin/klist jre/1.4.2/bin/ktab jre/1.4.2/bin/rmiregistry jre/1.4.2/bin/rmid jre/1.4.2/bin/orbd jre/1.4.2/bin/servertool jre/1.4.2/bin/tnameserv jre/1.4.2/bin/ControlPanel jre/1.4.2/bin/java_vm
chmod 664 jre/1.4.2/lib/i386/native_threads/libhpi.so jre/1.4.2/lib/i386/server/libjvm.so jre/1.4.2/lib/i386/server/Xusage.txt jre/1.4.2/lib/i386/client/libjvm.so jre/1.4.2/lib/i386/client/Xusage.txt jre/1.4.2/lib/i386/libnative_chmod.so jre/1.4.2/lib/i386/libjsig.so jre/1.4.2/lib/i386/libverify.so jre/1.4.2/lib/i386/libjava.so jre/1.4.2/lib/i386/jvm.cfg jre/1.4.2/lib/i386/libzip.so jre/1.4.2/lib/i386/libhprof.so jre/1.4.2/lib/i386/libjcov.so jre/1.4.2/lib/i386/libnet.so jre/1.4.2/lib/i386/libnio.so jre/1.4.2/lib/i386/libjsound.so jre/1.4.2/lib/i386/libjsoundalsa.so jre/1.4.2/lib/i386/libmlib_image.so jre/1.4.2/lib/i386/libawt.so jre/1.4.2/lib/i386/awt_robot jre/1.4.2/lib/i386/libdcpr.so jre/1.4.2/lib/i386/libfontmanager.so jre/1.4.2/lib/i386/libjpeg.so jre/1.4.2/lib/i386/libcmm.so jre/1.4.2/lib/i386/libioser12.so jre/1.4.2/lib/i386/librmi.so jre/1.4.2/lib/i386/libJdbcOdbc.so jre/1.4.2/lib/i386/libjawt.so jre/1.4.2/lib/i386/libjaas_unix.so jre/1.4.2/lib/i386/libjdwp.so jre/1.4.2/lib/i386/libdt_socket.so jre/1.4.2/lib/i386/libjavaplugin_jni.so jre/1.4.2/lib/ext/sunjce_provider.jar jre/1.4.2/lib/ext/dnsns.jar jre/1.4.2/lib/ext/ldapsec.jar jre/1.4.2/lib/ext/localedata.jar jre/1.4.2/lib/sunrsasign.jar jre/1.4.2/lib/jce.jar jre/1.4.2/lib/security/US_export_policy.jar jre/1.4.2/lib/security/local_policy.jar jre/1.4.2/lib/security/java.security jre/1.4.2/lib/security/java.policy jre/1.4.2/lib/security/cacerts jre/1.4.2/lib/fonts/LucidaTypewriterRegular.ttf jre/1.4.2/lib/fonts/LucidaTypewriterBold.ttf jre/1.4.2/lib/fonts/LucidaBrightRegular.ttf jre/1.4.2/lib/fonts/LucidaBrightDemiBold.ttf jre/1.4.2/lib/fonts/LucidaBrightItalic.ttf jre/1.4.2/lib/fonts/LucidaBrightDemiItalic.ttf jre/1.4.2/lib/fonts/LucidaSansRegular.ttf jre/1.4.2/lib/fonts/LucidaSansDemiBold.ttf jre/1.4.2/lib/fonts/LucidaTypewriterOblique.ttf jre/1.4.2/lib/fonts/LucidaTypewriterBoldOblique.ttf jre/1.4.2/lib/fonts/LucidaSansOblique.ttf jre/1.4.2/lib/fonts/LucidaSansDemiOblique.ttf jre/1.4.2/lib/fonts/fonts.dir jre/1.4.2/lib/content-types.properties jre/1.4.2/lib/jvm.hprof.txt jre/1.4.2/lib/jvm.jcov.txt jre/1.4.2/lib/flavormap.properties jre/1.4.2/lib/images/cursors/cursors.properties jre/1.4.2/lib/images/cursors/motif_CopyDrop32x32.gif jre/1.4.2/lib/images/cursors/motif_MoveDrop32x32.gif jre/1.4.2/lib/images/cursors/motif_LinkDrop32x32.gif jre/1.4.2/lib/images/cursors/motif_CopyNoDrop32x32.gif jre/1.4.2/lib/images/cursors/motif_MoveNoDrop32x32.gif jre/1.4.2/lib/images/cursors/motif_LinkNoDrop32x32.gif jre/1.4.2/lib/images/cursors/invalid32x32.gif jre/1.4.2/lib/logging.properties jre/1.4.2/lib/psfontj2d.properties jre/1.4.2/lib/psfont.properties.ja jre/1.4.2/lib/audio/soundbank.gm jre/1.4.2/lib/zi/Africa/Lusaka jre/1.4.2/lib/zi/Africa/Timbuktu jre/1.4.2/lib/zi/Africa/Bujumbura jre/1.4.2/lib/zi/Africa/Sao_Tome jre/1.4.2/lib/zi/Africa/Djibouti jre/1.4.2/lib/zi/Africa/El_Aaiun jre/1.4.2/lib/zi/Africa/Kampala jre/1.4.2/lib/zi/Africa/Gaborone jre/1.4.2/lib/zi/Africa/Mogadishu jre/1.4.2/lib/zi/Africa/Ndjamena jre/1.4.2/lib/zi/Africa/Libreville jre/1.4.2/lib/zi/Africa/Nairobi jre/1.4.2/lib/zi/Africa/Abidjan jre/1.4.2/lib/zi/Africa/Tunis jre/1.4.2/lib/zi/Africa/Harare jre/1.4.2/lib/zi/Africa/Addis_Ababa jre/1.4.2/lib/zi/Africa/Algiers jre/1.4.2/lib/zi/Africa/Cairo jre/1.4.2/lib/zi/Africa/Porto-Novo jre/1.4.2/lib/zi/Africa/Lubumbashi jre/1.4.2/lib/zi/Africa/Mbabane jre/1.4.2/lib/zi/Africa/Ouagadougou jre/1.4.2/lib/zi/Africa/Kinshasa jre/1.4.2/lib/zi/Africa/Niamey jre/1.4.2/lib/zi/Africa/Lome jre/1.4.2/lib/zi/Africa/Lagos jre/1.4.2/lib/zi/Africa/Bissau jre/1.4.2/lib/zi/Africa/Brazzaville jre/1.4.2/lib/zi/Africa/Blantyre jre/1.4.2/lib/zi/Africa/Tripoli jre/1.4.2/lib/zi/Africa/Dar_es_Salaam jre/1.4.2/lib/zi/Africa/Douala jre/1.4.2/lib/zi/Africa/Banjul jre/1.4.2/lib/zi/Africa/Dakar jre/1.4.2/lib/zi/Africa/Khartoum jre/1.4.2/lib/zi/Africa/Bangui jre/1.4.2/lib/zi/Africa/Kigali jre/1.4.2/lib/zi/Africa/Windhoek jre/1.4.2/lib/zi/Africa/Johannesburg jre/1.4.2/lib/zi/Africa/Asmera jre/1.4.2/lib/zi/Africa/Casablanca jre/1.4.2/lib/zi/Africa/Nouakchott jre/1.4.2/lib/zi/Africa/Malabo jre/1.4.2/lib/zi/Africa/Conakry jre/1.4.2/lib/zi/Africa/Accra jre/1.4.2/lib/zi/Africa/Freetown jre/1.4.2/lib/zi/Africa/Maputo jre/1.4.2/lib/zi/Africa/Luanda jre/1.4.2/lib/zi/Africa/Bamako jre/1.4.2/lib/zi/Africa/Maseru jre/1.4.2/lib/zi/Africa/Monrovia jre/1.4.2/lib/zi/Africa/Ceuta jre/1.4.2/lib/zi/America/Scoresbysund jre/1.4.2/lib/zi/America/Danmarkshavn jre/1.4.2/lib/zi/America/Godthab jre/1.4.2/lib/zi/America/Thule jre/1.4.2/lib/zi/America/St_Kitts jre/1.4.2/lib/zi/America/Los_Angeles jre/1.4.2/lib/zi/America/Barbados jre/1.4.2/lib/zi/America/Nassau jre/1.4.2/lib/zi/America/Dominica jre/1.4.2/lib/zi/America/Montreal jre/1.4.2/lib/zi/America/Whitehorse jre/1.4.2/lib/zi/America/Monterrey jre/1.4.2/lib/zi/America/Chihuahua jre/1.4.2/lib/zi/America/Thunder_Bay jre/1.4.2/lib/zi/America/Swift_Current jre/1.4.2/lib/zi/America/Glace_Bay jre/1.4.2/lib/zi/America/Antigua jre/1.4.2/lib/zi/America/Boise jre/1.4.2/lib/zi/America/Edmonton jre/1.4.2/lib/zi/America/Anchorage jre/1.4.2/lib/zi/America/Merida jre/1.4.2/lib/zi/America/Panama jre/1.4.2/lib/zi/America/Menominee jre/1.4.2/lib/zi/America/Mexico_City jre/1.4.2/lib/zi/America/Cayman jre/1.4.2/lib/zi/America/Indianapolis jre/1.4.2/lib/zi/America/Juneau jre/1.4.2/lib/zi/America/Cambridge_Bay jre/1.4.2/lib/zi/America/Dawson jre/1.4.2/lib/zi/America/Indiana/Marengo jre/1.4.2/lib/zi/America/Indiana/Knox jre/1.4.2/lib/zi/America/Indiana/Vevay jre/1.4.2/lib/zi/America/Yakutat jre/1.4.2/lib/zi/America/Pangnirtung jre/1.4.2/lib/zi/America/Port-au-Prince jre/1.4.2/lib/zi/America/Cancun jre/1.4.2/lib/zi/America/Nipigon jre/1.4.2/lib/zi/America/North_Dakota/Center jre/1.4.2/lib/zi/America/Yellowknife jre/1.4.2/lib/zi/America/Guatemala jre/1.4.2/lib/zi/America/Kentucky/Monticello jre/1.4.2/lib/zi/America/St_Lucia jre/1.4.2/lib/zi/America/Guadeloupe jre/1.4.2/lib/zi/America/Iqaluit jre/1.4.2/lib/zi/America/Tijuana jre/1.4.2/lib/zi/America/Inuvik jre/1.4.2/lib/zi/America/Miquelon jre/1.4.2/lib/zi/America/Anguilla jre/1.4.2/lib/zi/America/Montserrat jre/1.4.2/lib/zi/America/Chicago jre/1.4.2/lib/zi/America/Managua jre/1.4.2/lib/zi/America/Halifax jre/1.4.2/lib/zi/America/St_Vincent jre/1.4.2/lib/zi/America/Regina jre/1.4.2/lib/zi/America/Belize jre/1.4.2/lib/zi/America/Louisville jre/1.4.2/lib/zi/America/Havana jre/1.4.2/lib/zi/America/Grand_Turk jre/1.4.2/lib/zi/America/Winnipeg jre/1.4.2/lib/zi/America/Jamaica jre/1.4.2/lib/zi/America/Detroit jre/1.4.2/lib/zi/America/Puerto_Rico jre/1.4.2/lib/zi/America/St_Johns jre/1.4.2/lib/zi/America/Nome jre/1.4.2/lib/zi/America/Martinique jre/1.4.2/lib/zi/America/Rainy_River jre/1.4.2/lib/zi/America/Mazatlan jre/1.4.2/lib/zi/America/Dawson_Creek jre/1.4.2/lib/zi/America/St_Thomas jre/1.4.2/lib/zi/America/Tortola jre/1.4.2/lib/zi/America/Goose_Bay jre/1.4.2/lib/zi/America/Costa_Rica jre/1.4.2/lib/zi/America/Grenada jre/1.4.2/lib/zi/America/El_Salvador jre/1.4.2/lib/zi/America/Vancouver jre/1.4.2/lib/zi/America/Hermosillo jre/1.4.2/lib/zi/America/Adak jre/1.4.2/lib/zi/America/Santo_Domingo jre/1.4.2/lib/zi/America/Phoenix jre/1.4.2/lib/zi/America/Tegucigalpa jre/1.4.2/lib/zi/America/Denver jre/1.4.2/lib/zi/America/New_York jre/1.4.2/lib/zi/America/Rankin_Inlet jre/1.4.2/lib/zi/America/La_Paz jre/1.4.2/lib/zi/America/Catamarca jre/1.4.2/lib/zi/America/Belem jre/1.4.2/lib/zi/America/Jujuy jre/1.4.2/lib/zi/America/Maceio jre/1.4.2/lib/zi/America/Araguaina jre/1.4.2/lib/zi/America/Sao_Paulo jre/1.4.2/lib/zi/America/Bogota jre/1.4.2/lib/zi/America/Aruba jre/1.4.2/lib/zi/America/Eirunepe jre/1.4.2/lib/zi/America/Asuncion jre/1.4.2/lib/zi/America/Santiago jre/1.4.2/lib/zi/America/Port_of_Spain jre/1.4.2/lib/zi/America/Manaus jre/1.4.2/lib/zi/America/Caracas jre/1.4.2/lib/zi/America/Noronha jre/1.4.2/lib/zi/America/Buenos_Aires jre/1.4.2/lib/zi/America/Guyana jre/1.4.2/lib/zi/America/Cayenne jre/1.4.2/lib/zi/America/Fortaleza jre/1.4.2/lib/zi/America/Boa_Vista jre/1.4.2/lib/zi/America/Paramaribo jre/1.4.2/lib/zi/America/Porto_Velho jre/1.4.2/lib/zi/America/Recife jre/1.4.2/lib/zi/America/Mendoza jre/1.4.2/lib/zi/America/Lima jre/1.4.2/lib/zi/America/Guayaquil jre/1.4.2/lib/zi/America/Montevideo jre/1.4.2/lib/zi/America/Cuiaba jre/1.4.2/lib/zi/America/Rio_Branco jre/1.4.2/lib/zi/America/Curacao jre/1.4.2/lib/zi/America/Cordoba jre/1.4.2/lib/zi/Antarctica/Vostok jre/1.4.2/lib/zi/Antarctica/Syowa jre/1.4.2/lib/zi/Antarctica/Palmer jre/1.4.2/lib/zi/Antarctica/Davis jre/1.4.2/lib/zi/Antarctica/Rothera jre/1.4.2/lib/zi/Antarctica/Casey jre/1.4.2/lib/zi/Antarctica/McMurdo jre/1.4.2/lib/zi/Antarctica/Mawson jre/1.4.2/lib/zi/Antarctica/DumontDUrville jre/1.4.2/lib/zi/Asia/Rangoon jre/1.4.2/lib/zi/Asia/Choibalsan jre/1.4.2/lib/zi/Asia/Kabul jre/1.4.2/lib/zi/Asia/Kuala_Lumpur jre/1.4.2/lib/zi/Asia/Bangkok jre/1.4.2/lib/zi/Asia/Brunei jre/1.4.2/lib/zi/Asia/Aqtau
chmod 664 jre/1.4.2/lib/zi/Asia/Tbilisi jre/1.4.2/lib/zi/Asia/Katmandu jre/1.4.2/lib/zi/Asia/Aden jre/1.4.2/lib/zi/Asia/Baghdad jre/1.4.2/lib/zi/Asia/Aqtobe jre/1.4.2/lib/zi/Asia/Pontianak jre/1.4.2/lib/zi/Asia/Makassar jre/1.4.2/lib/zi/Asia/Seoul jre/1.4.2/lib/zi/Asia/Urumqi jre/1.4.2/lib/zi/Asia/Kashgar jre/1.4.2/lib/zi/Asia/Ashgabat jre/1.4.2/lib/zi/Asia/Qyzylorda jre/1.4.2/lib/zi/Asia/Chongqing jre/1.4.2/lib/zi/Asia/Kuching jre/1.4.2/lib/zi/Asia/Tashkent jre/1.4.2/lib/zi/Asia/Dili jre/1.4.2/lib/zi/Asia/Tokyo jre/1.4.2/lib/zi/Asia/Dubai jre/1.4.2/lib/zi/Asia/Colombo jre/1.4.2/lib/zi/Asia/Qatar jre/1.4.2/lib/zi/Asia/Bishkek jre/1.4.2/lib/zi/Asia/Manila jre/1.4.2/lib/zi/Asia/Karachi jre/1.4.2/lib/zi/Asia/Thimphu jre/1.4.2/lib/zi/Asia/Hovd jre/1.4.2/lib/zi/Asia/Yerevan jre/1.4.2/lib/zi/Asia/Baku jre/1.4.2/lib/zi/Asia/Oral jre/1.4.2/lib/zi/Asia/Ulaanbaatar jre/1.4.2/lib/zi/Asia/Jakarta jre/1.4.2/lib/zi/Asia/Beirut jre/1.4.2/lib/zi/Asia/Pyongyang jre/1.4.2/lib/zi/Asia/Bahrain jre/1.4.2/lib/zi/Asia/Phnom_Penh jre/1.4.2/lib/zi/Asia/Saigon jre/1.4.2/lib/zi/Asia/Jerusalem jre/1.4.2/lib/zi/Asia/Shanghai jre/1.4.2/lib/zi/Asia/Kuwait jre/1.4.2/lib/zi/Asia/Damascus jre/1.4.2/lib/zi/Asia/Nicosia jre/1.4.2/lib/zi/Asia/Hong_Kong jre/1.4.2/lib/zi/Asia/Riyadh jre/1.4.2/lib/zi/Asia/Almaty jre/1.4.2/lib/zi/Asia/Harbin jre/1.4.2/lib/zi/Asia/Gaza jre/1.4.2/lib/zi/Asia/Dhaka jre/1.4.2/lib/zi/Asia/Vientiane jre/1.4.2/lib/zi/Asia/Dushanbe jre/1.4.2/lib/zi/Asia/Macau jre/1.4.2/lib/zi/Asia/Singapore jre/1.4.2/lib/zi/Asia/Samarkand jre/1.4.2/lib/zi/Asia/Taipei jre/1.4.2/lib/zi/Asia/Muscat jre/1.4.2/lib/zi/Asia/Amman jre/1.4.2/lib/zi/Asia/Calcutta jre/1.4.2/lib/zi/Asia/Jayapura jre/1.4.2/lib/zi/Asia/Tehran jre/1.4.2/lib/zi/Asia/Sakhalin jre/1.4.2/lib/zi/Asia/Irkutsk jre/1.4.2/lib/zi/Asia/Novosibirsk jre/1.4.2/lib/zi/Asia/Omsk jre/1.4.2/lib/zi/Asia/Krasnoyarsk jre/1.4.2/lib/zi/Asia/Yekaterinburg jre/1.4.2/lib/zi/Asia/Kamchatka jre/1.4.2/lib/zi/Asia/Magadan jre/1.4.2/lib/zi/Asia/Vladivostok jre/1.4.2/lib/zi/Asia/Anadyr jre/1.4.2/lib/zi/Asia/Yakutsk jre/1.4.2/lib/zi/Asia/Riyadh87 jre/1.4.2/lib/zi/Asia/Riyadh88 jre/1.4.2/lib/zi/Asia/Riyadh89 jre/1.4.2/lib/zi/Atlantic/St_Helena jre/1.4.2/lib/zi/Atlantic/Cape_Verde jre/1.4.2/lib/zi/Atlantic/Madeira jre/1.4.2/lib/zi/Atlantic/Reykjavik jre/1.4.2/lib/zi/Atlantic/Faeroe jre/1.4.2/lib/zi/Atlantic/Azores jre/1.4.2/lib/zi/Atlantic/Canary jre/1.4.2/lib/zi/Atlantic/Bermuda jre/1.4.2/lib/zi/Atlantic/Stanley jre/1.4.2/lib/zi/Atlantic/South_Georgia jre/1.4.2/lib/zi/Australia/Melbourne jre/1.4.2/lib/zi/Australia/Brisbane jre/1.4.2/lib/zi/Australia/Adelaide jre/1.4.2/lib/zi/Australia/Broken_Hill jre/1.4.2/lib/zi/Australia/Lindeman jre/1.4.2/lib/zi/Australia/Perth jre/1.4.2/lib/zi/Australia/Darwin jre/1.4.2/lib/zi/Australia/Lord_Howe jre/1.4.2/lib/zi/Australia/Sydney jre/1.4.2/lib/zi/Australia/Hobart jre/1.4.2/lib/zi/CET jre/1.4.2/lib/zi/EET jre/1.4.2/lib/zi/Etc/GMT+7 jre/1.4.2/lib/zi/Etc/GMT-8 jre/1.4.2/lib/zi/Etc/GMT+8 jre/1.4.2/lib/zi/Etc/UTC jre/1.4.2/lib/zi/Etc/UCT jre/1.4.2/lib/zi/Etc/GMT-3 jre/1.4.2/lib/zi/Etc/GMT+12 jre/1.4.2/lib/zi/Etc/GMT+1 jre/1.4.2/lib/zi/Etc/GMT-11 jre/1.4.2/lib/zi/Etc/GMT-7 jre/1.4.2/lib/zi/Etc/GMT+6 jre/1.4.2/lib/zi/Etc/GMT+11 jre/1.4.2/lib/zi/Etc/GMT-14 jre/1.4.2/lib/zi/Etc/GMT+2 jre/1.4.2/lib/zi/Etc/GMT-5 jre/1.4.2/lib/zi/Etc/GMT-13 jre/1.4.2/lib/zi/Etc/GMT+3 jre/1.4.2/lib/zi/Etc/GMT-4 jre/1.4.2/lib/zi/Etc/GMT-12 jre/1.4.2/lib/zi/Etc/GMT+4 jre/1.4.2/lib/zi/Etc/GMT+9 jre/1.4.2/lib/zi/Etc/GMT-1 jre/1.4.2/lib/zi/Etc/GMT+5 jre/1.4.2/lib/zi/Etc/GMT jre/1.4.2/lib/zi/Etc/GMT-2 jre/1.4.2/lib/zi/Etc/GMT-6 jre/1.4.2/lib/zi/Etc/GMT-9 jre/1.4.2/lib/zi/Etc/GMT+10 jre/1.4.2/lib/zi/Etc/GMT-10 jre/1.4.2/lib/zi/Europe/Chisinau jre/1.4.2/lib/zi/Europe/Moscow jre/1.4.2/lib/zi/Europe/Paris jre/1.4.2/lib/zi/Europe/Riga jre/1.4.2/lib/zi/Europe/Lisbon jre/1.4.2/lib/zi/Europe/Vaduz jre/1.4.2/lib/zi/Europe/Belgrade jre/1.4.2/lib/zi/Europe/Berlin jre/1.4.2/lib/zi/Europe/Luxembourg jre/1.4.2/lib/zi/Europe/Oslo jre/1.4.2/lib/zi/Europe/Uzhgorod jre/1.4.2/lib/zi/Europe/Istanbul jre/1.4.2/lib/zi/Europe/Madrid jre/1.4.2/lib/zi/Europe/Belfast jre/1.4.2/lib/zi/Europe/Minsk jre/1.4.2/lib/zi/Europe/Rome jre/1.4.2/lib/zi/Europe/Warsaw jre/1.4.2/lib/zi/Europe/Tirane jre/1.4.2/lib/zi/Europe/Helsinki jre/1.4.2/lib/zi/Europe/Vilnius jre/1.4.2/lib/zi/Europe/Stockholm jre/1.4.2/lib/zi/Europe/Amsterdam jre/1.4.2/lib/zi/Europe/Prague jre/1.4.2/lib/zi/Europe/Dublin jre/1.4.2/lib/zi/Europe/Vienna jre/1.4.2/lib/zi/Europe/London jre/1.4.2/lib/zi/Europe/Tallinn jre/1.4.2/lib/zi/Europe/Kaliningrad jre/1.4.2/lib/zi/Europe/Samara jre/1.4.2/lib/zi/Europe/Malta jre/1.4.2/lib/zi/Europe/Sofia jre/1.4.2/lib/zi/Europe/Zurich jre/1.4.2/lib/zi/Europe/Zaporozhye jre/1.4.2/lib/zi/Europe/Gibraltar jre/1.4.2/lib/zi/Europe/Budapest jre/1.4.2/lib/zi/Europe/Simferopol jre/1.4.2/lib/zi/Europe/Athens jre/1.4.2/lib/zi/Europe/Copenhagen jre/1.4.2/lib/zi/Europe/Monaco jre/1.4.2/lib/zi/Europe/Andorra jre/1.4.2/lib/zi/Europe/Bucharest jre/1.4.2/lib/zi/Europe/Brussels jre/1.4.2/lib/zi/Europe/Kiev jre/1.4.2/lib/zi/GMT jre/1.4.2/lib/zi/Indian/Reunion jre/1.4.2/lib/zi/Indian/Antananarivo jre/1.4.2/lib/zi/Indian/Mahe jre/1.4.2/lib/zi/Indian/Mayotte jre/1.4.2/lib/zi/Indian/Comoro jre/1.4.2/lib/zi/Indian/Mauritius jre/1.4.2/lib/zi/Indian/Kerguelen jre/1.4.2/lib/zi/Indian/Chagos jre/1.4.2/lib/zi/Indian/Maldives jre/1.4.2/lib/zi/Indian/Cocos jre/1.4.2/lib/zi/Indian/Christmas jre/1.4.2/lib/zi/MET jre/1.4.2/lib/zi/Pacific/Kosrae jre/1.4.2/lib/zi/Pacific/Kwajalein jre/1.4.2/lib/zi/Pacific/Marquesas jre/1.4.2/lib/zi/Pacific/Port_Moresby jre/1.4.2/lib/zi/Pacific/Tongatapu jre/1.4.2/lib/zi/Pacific/Wallis jre/1.4.2/lib/zi/Pacific/Truk jre/1.4.2/lib/zi/Pacific/Wake jre/1.4.2/lib/zi/Pacific/Funafuti jre/1.4.2/lib/zi/Pacific/Pago_Pago jre/1.4.2/lib/zi/Pacific/Norfolk jre/1.4.2/lib/zi/Pacific/Midway jre/1.4.2/lib/zi/Pacific/Guadalcanal jre/1.4.2/lib/zi/Pacific/Tarawa jre/1.4.2/lib/zi/Pacific/Noumea jre/1.4.2/lib/zi/Pacific/Fakaofo jre/1.4.2/lib/zi/Pacific/Fiji jre/1.4.2/lib/zi/Pacific/Johnston jre/1.4.2/lib/zi/Pacific/Kiritimati jre/1.4.2/lib/zi/Pacific/Ponape jre/1.4.2/lib/zi/Pacific/Enderbury jre/1.4.2/lib/zi/Pacific/Guam jre/1.4.2/lib/zi/Pacific/Majuro jre/1.4.2/lib/zi/Pacific/Niue jre/1.4.2/lib/zi/Pacific/Tahiti jre/1.4.2/lib/zi/Pacific/Rarotonga jre/1.4.2/lib/zi/Pacific/Palau jre/1.4.2/lib/zi/Pacific/Chatham jre/1.4.2/lib/zi/Pacific/Auckland jre/1.4.2/lib/zi/Pacific/Pitcairn jre/1.4.2/lib/zi/Pacific/Yap jre/1.4.2/lib/zi/Pacific/Gambier jre/1.4.2/lib/zi/Pacific/Apia jre/1.4.2/lib/zi/Pacific/Efate jre/1.4.2/lib/zi/Pacific/Saipan jre/1.4.2/lib/zi/Pacific/Nauru jre/1.4.2/lib/zi/Pacific/Honolulu jre/1.4.2/lib/zi/Pacific/Easter jre/1.4.2/lib/zi/Pacific/Galapagos jre/1.4.2/lib/zi/WET jre/1.4.2/lib/zi/ZoneInfoMappings jre/1.4.2/lib/cmm/sRGB.pf jre/1.4.2/lib/cmm/GRAY.pf jre/1.4.2/lib/cmm/CIEXYZ.pf jre/1.4.2/lib/cmm/PYCC.pf jre/1.4.2/lib/cmm/LINEAR_RGB.pf jre/1.4.2/lib/im/indicim.jar jre/1.4.2/lib/im/thaiim.jar jre/1.4.2/lib/locale/de/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/es/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/fr/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/it/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/ja/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/ko/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/ko.UTF-8/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/sv/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/zh/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/zh.GBK/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/zh_TW/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/locale/zh_TW.BIG5/LC_MESSAGES/sunw_java_plugin.mo jre/1.4.2/lib/jsse.jar jre/1.4.2/lib/charsets.jar jre/1.4.2/lib/plugin.jar jre/1.4.2/lib/rt.jar jre/1.4.2/CHANGES jre/1.4.2/COPYRIGHT jre/1.4.2/Welcome.html jre/1.4.2/README jre/1.4.2/LICENSE jre/1.4.2/THIRDPARTYLICENSEREADME.txt jre/1.4.2/plugin/desktop/sun_java.png jre/1.4.2/plugin/desktop/sun_java.desktop jre/1.4.2/plugin/i386/ns4/libjavaplugin.so jre/1.4.2/plugin/i386/ns610/libjavaplugin_oji.so jre/1.4.2/plugin/i386/ns610-gcc32/libjavaplugin_oji.so jre/1.4.2/ControlPanel.html jre/1.4.2/javaws/cacerts
chmod 664 jre/1.4.2/javaws/javalogo52x88.gif jre/1.4.2/javaws/javaws jre/1.4.2/javaws/javaws-l10n.jar jre/1.4.2/javaws/javaws.policy jre/1.4.2/javaws/javawsbin jre/1.4.2/javaws/readme.html jre/1.4.2/javaws/readme_de.html jre/1.4.2/javaws/readme_es.html jre/1.4.2/javaws/readme_fr.html jre/1.4.2/javaws/readme_it.html jre/1.4.2/javaws/readme_ja.html jre/1.4.2/javaws/readme_ko.html jre/1.4.2/javaws/readme_sv.html jre/1.4.2/javaws/readme_zh_CN.html jre/1.4.2/javaws/readme_zh_TW.html jre/1.4.2/javaws/resources/splash.jpg jre/1.4.2/javaws/resources/miniSplash.jpg jre/1.4.2/javaws/resources/copyright.jpg jre/1.4.2/javaws/resources/messages.properties jre/1.4.2/javaws/resources/messages_zh_TW.properties jre/1.4.2/javaws/resources/messages_de.properties jre/1.4.2/javaws/resources/messages_es.properties jre/1.4.2/javaws/resources/messages_fr.properties jre/1.4.2/javaws/resources/messages_it.properties jre/1.4.2/javaws/resources/messages_ja.properties jre/1.4.2/javaws/resources/messages_ko.properties jre/1.4.2/javaws/resources/messages_sv.properties jre/1.4.2/javaws/resources/messages_zh_CN.properties jre/1.4.2/javaws/sunlogo64x30.gif jre/1.4.2/javaws/javaws.jar jre/1.4.2/lib/README jre/1.4.2/lib/charsets.jar jre/1.4.2/lib/content-types.properties jre/1.4.2/lib/flavormap.properties jre/1.4.2/lib/font.properties jre/1.4.2/lib/font.properties.Redhat6.1 jre/1.4.2/lib/font.properties.Redhat8.0 jre/1.4.2/lib/font.properties.SuSE8.0 jre/1.4.2/lib/font.properties.ja jre/1.4.2/lib/font.properties.ja.Redhat6.1 jre/1.4.2/lib/font.properties.ja.Redhat6.2 jre/1.4.2/lib/font.properties.ja.Redhat7.2 jre/1.4.2/lib/font.properties.ja.Redhat7.3 jre/1.4.2/lib/font.properties.ja.Redhat8.0 jre/1.4.2/lib/font.properties.ja.Sun jre/1.4.2/lib/font.properties.ja.Turbo jre/1.4.2/lib/font.properties.ja.Turbo6.0 jre/1.4.2/lib/font.properties.ja_JP_UTF8.Sun jre/1.4.2/lib/font.properties.ko.Redhat jre/1.4.2/lib/font.properties.zh.Turbo jre/1.4.2/lib/font.properties.zh_CN.Redhat jre/1.4.2/lib/font.properties.zh_CN.Redhat2.1 jre/1.4.2/lib/font.properties.zh_CN.Sun jre/1.4.2/lib/font.properties.zh_CN_UTF8.Sun jre/1.4.2/lib/font.properties.zh_TW.Redhat jre/1.4.2/lib/font.properties.zh_TW.Sun jre/1.4.2/lib/font.properties.zh_TW_UTF8.Sun jre/1.4.2/lib/jce.jar jre/1.4.2/lib/jsse.jar jre/1.4.2/lib/jvm.hprof.txt jre/1.4.2/lib/jvm.jcov.txt jre/1.4.2/lib/logging.properties jre/1.4.2/lib/plugin.jar jre/1.4.2/lib/psfont.properties.ja jre/1.4.2/lib/psfontj2d.properties jre/1.4.2/lib/rt.jar jre/1.4.2/lib/sunrsasign.jar
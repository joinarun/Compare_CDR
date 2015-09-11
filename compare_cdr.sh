#!/bin/env bash
column=(column1 column2 column3 column4 column5);


if [ $# -lt 2 ]
then
   echo "Usage: $0 refernce_file actual_cdr_file";
   echo "Example: $0 sms_ref_001.CDR I0111032013_19_22_48_00006.CDR";
   exit 3;
fi
        if [ -r $1 ]
        then
		    if [ ! -r $2 ]
			then
			    echo "No such file : $2";
				exit;
		    fi
		else
		    echo "No such file : $1";
			exit;
		fi


		
################################## The columns entered here are only considered #######################

                cat $1 | cut -d, -f1-21,25-30,32-33 >> t
                cat $2 | sed 's/0/0/' | cut -d, -f1-21,25-30,32-33 >> t1

########################################################################################################



                diff t t1 >/dev/null
                if [ $? -eq 0 ]
                then
                        echo "PASS: Compared datas are identical";
						rm -rf t t1;
						exit 0;
                else
                       echo "FAIL: Compared datas are non-identical";
#Logic to detect mismatch
                function compare_files(){
                file1=$1
                file2=$2
                file1_lines=`wc -l $file1 | awk {'print $1'}`
                file2_lines=`wc -l $file2 | awk {'print $1'}`
                if [ $file1_lines -ne $file2_lines ]
                then
                     echo "No. of lines in CDR mismatched.(Expected: $file1_lines , Actual: $file2_lines)"
                else
                   file_lines=$file1_lines;
                   for((i=1;i<=$file_lines;i++)){
                      OLDIFS=$IFS
                      IFS=','
                      file1_array=(` head -$i $file1 | tail -1`)
                      file2_array=(` head -$i $file2 | tail -1`)
                      if [ ${#file1_array[@]} -ne ${#file2_array[@]} ]
                      then
                          echo "No. of columns mismatched. (Expected: ${#file1_array[@]} , Actual: ${#file2_array[@]} ) ";
                      else
                          file_array=${#file2_array[@]};
                          for((j=0;j<=$file_array;j++)){
                              case ${file2_array[$j]} in
                                 ${file1_array[$j]}):;;
                                 *)echo "Mismatch found at line:($i,${column[$j]}) (Expected: ${file1_array[$j]} , Actual: ${file2_array[$j]})";;
                              esac
                         }
                      fi
                      }
                 fi
                }
                compare_files t t1
                IFS=$OLDIFS
#End of logic to detect mismatch
                rm -f t t1 ;
                exit 1;
			fi

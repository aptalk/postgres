#!/bin/bash

grantuser()
{
    db_name=$1
    schema=$2
    schema_list=$3
    is_role=$4
    function_comments=$5
    table_comments=$6
    tabledml_comments=$7
    exclusion_table_comments=$8

    local some_sql=""

    # Replace CLIENT with the lower client name
    schema_list=$(echo ${schema_list} | sed "s#CLIENT#${client_name_lower}#g" | tr -d '"')
    #set +x
    #echo "schema_list without public: ${schema_list}"

    db_user=${db_name}_${schema}


    if [ "$is_role" == "ROLE" ] ;
    then
      p_is_role=t
    else
      p_is_role=f
    fi
    #echo is_role is  "$p_is_role"
    some_sql="select yobota_security.determine_permissions ('${db_user}', '{${schema_list}}', '${p_is_role}', '${function_comments}', '${table_comments}', '${tabledml_comments}', '${exclusion_table_comments}' );"
    #echo "some_sql: ${some_sql}"
    psql -t ${MY_WORKER_DATABASE_URL} <<<"${some_sql}"

} # end of grantuser
echo 'First arg:' $1
echo 'Second arg:' $2

MY_WORKER_DATABASE_URL=$1
echo "${MY_WORKER_DATABASE_URL}"

db_name="ops_${2}"

#some_sql="SELECT * FROM yobota_security.old_schema_usage;"
#psql -t ${MY_WORKER_DATABASE_URL} <<<"${some_sql}"

IFS=$'\n'
#for i in $(tail -n+2 ../users/schema_user_list.sql)
for i in $(tail -n+2 /home/andrew/workspace/YobotaDatabase/users/schema_user_list.sql)
do
    IFS=' ' read -r -a array <<< $i
    #echo grantuser "${db_name}" "${array[0]}" "${array[1]}" "${array[2]}" "${array[3]}" "${array[4]}" "${array[5]}" "${array[6]}"
    grantuser "${db_name}" "${array[0]}" "${array[1]}" "${array[2]}" "${array[3]}" "${array[4]}" "${array[5]}" "${array[6]}"
done


#Example call:>   /bin/bash /home/andrew/.config/JetBrains/PyCharm2020.3/scratches/_andrew_test.sh --MY_WORKER_DATABASE_URL "postgresql://postgres-dev-pg11.cqge30bitdmo.eu-west-1.rds.amazonaws.com:5432/ops_andrew?user=yobotadba&password=9002890028&ssl=true&sslmode=require" --db_name andrew


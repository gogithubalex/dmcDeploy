#!/bin/bash
#importing devUtil
source devUtils/devUtil.sh


spacer The following script will help you deploy and manage your DMC stack.
printf "\n###############################################################################################"

printf " \nThis script will create a user specific directory for you. \nWhat shall we call thee? [ENTER][q to quit] "
read uname
if [ -z "$uname" ]
  then
    printf "\nNo arguments supplied quitting"
    exit
fi
case $uname in [qQ]) exit;; esac

if [[ ! -d ~/$uname ]];
   then
    # dir does not exist under that name make it
    printf "\nCreating your work dir in ~/$uname"
    mkdir ~/$uname
    cd ~/$uname/
    # clone dmcdeploy
    printf "\nClonning dmcdeploy into your directory"
    git clone https://bitbucket.org/DigitalMfgCommons/dmcdeploy.git
  else
    printf "\nGood to see you again $uname.";
    printf "\nNavigating to ~/$uname";


fi



cd ~/$uname/dmcdeploy
git checkout DMC-590-deploy-ui-labs-instance
printf "\nUpdating the repo ..."
git pull
printf "\nYour code base is up to date.";

printf "\nWhich cloud would you like to deploy to?";
printf "\n1. Amazon Web Services"
printf "\n2. Microsoft Azure"
printf "\n[q to quit]"
read -n 1 cloudChoice
printf "\nYou chose $cloudChoice"

case $cloudChoice
  in [qQ])
    exit;;
   1)
    cloudChoice="AWS"
   ;;
   2)
    cloudChoice="Azure"
   ;;
   *)
    exit
    ;;
esac

cd $cloudChoice

printf "\nWhat would you like to do?  [ENTER][q to quit] "
printf "\n1. Create a new DMC Stack"
printf "\n2. Update an existing DMC Stack Infrastructure"
printf "\n3. Update the codebase on an Existing DMC Stack without altering the infrastructure"
printf "\n4. Destroy existing DMC Stack Infrastructure"
read -n 1 choice

printf "\nYou chose $choice"
case $choice in [qQ]) exit;; esac
if [ $choice == 1 ]
  then

   if [ -f terraform.tfstate ]
     then
       terraform show
       printf "You have existing infrastructure on aws."

       printf "If you continue this script will edit that infrastructure in place.\n Would you like to continue? [y] [q to quit].\n You may wish to quit now and use terraform destroy to remove the infrastructure and rerun this script to make a new set.\n"
       read tfstate
       case $tfstate in [qQ]) exit;; esac
   fi




    printf "\nCreating a new stack. \n Will need more information."
    printf "\nWhat kind of stack would you like to deploy?"
    printf "\n1. Development Stack"
    printf "\n2. Production Stack \n"
    read -n 1 schoice
    if [ $schoice == 1 ]; then
      printf "\nCreating Developmnet Stack"
      scripts/populateTerraformtfvarsDevAWS.sh $uname
    else
      printf "\n Production Stack"
      printf "\n That part is not yet automated."
      exit

    fi

    terraform plan
    printf  "\n Are you happy with the terrafom plan described above? \n Must answer yes or progam will not create your infrastructure. \n If you disagree go back and edit your terrafom.tfvars file manually and execute terraform apply.  [yes][q to quit] "
    read apply
    case $apply in [qQ]) exit;; esac
    if [ $apply == yes ]
      then
        terraform apply
        printf "\nResults of Sanity Test Front"
        cat frontSanityTest.log
        printf "\nResults of Sanity Test Rest"
        cat restSanityTest.log
        printf "\nLink the Stack Machines Together"
        ./linkMachines.sh
        printf "\nTightening the Dev Security groups where apropriate for the Dev Stack."
        ./tightenSgDev.sh
        printf "\nLastly you must add your infrastructure to the appropriate LOAD BALANCER -- ex. ben-web in aws-west-2"

        printf "\nGreat Job Pal. "
      else
       exit
    fi
    removePII ../terraform.tfvars
fi


if [ $choice == 2 ]
  then
  addPII
  printf "\nUpdating your existing infrastructure."
  printf "\n At the moment only the infrastructure found on the front end machine can be updated without destroying the rest of the stack. \n Do you wish to upgrade the infrastructure underpinning the frontend machine? [yes to upgrade ][q to quit]"
  read taintfront
  case $taintfront
    in [qQ])
     exit
     ;;
     yes)
       terrafom taint aws_instance.fornt
       terrafom apply
     ;;
  esac

  removePII
fi

if [ $choice == 3 ]
  then

    if [ ! -f terraform.tfstate ]; then
      printf "\nNo terrafom.tfstate found EXITING.\n Ensure you have a running stack."
      exit
    fi

  source ./updateStack.sh
  addPII
  printf "\nWhich instance do you wish to update? [q to quit]\n"
  printf "\n1. Front End Machine"
  printf "\n2. Rest Machine"
  printf "\n3. Db Machine"
  printf "\n4. Solr Machine"
  printf "\n5. Update all stack components to latest available builds. "
  read -n 1 iupdate
  case $iupdate
     in [qQ])
       exit;;
      1)

      serverURL=$(removeQuotes $serverURL)
      printf "\nWhich build do you wish to deploy? [hot -- latest] [ commit hash -- for particular build] [q to quit]\n"
      read fbuild
      case $fbuild in [qQ]) exit;; esac
      printf "updating the front with $serverURL >> from commit $fbuild"
      updateFront $serverURL $fbuild


      ;;
      2)
      printf "\nWhich build do you wish to deploy on the rest machine? [hot -- latest] [ commit hash -- for particular build] [q to quit]\n"
      read fbuild
      case $fbuild in [qQ]) exit;; esac
      printf "\nUpdating the rest machine  >> from commit $fbuild"
      updateRest $fbuild

      ;;
      3)
       printf "\nWhich build do you wish to deploy on the db machine? [hot -- latest] [ commit hash -- for particular build] [q to quit]\n"
       read fbuild
       case $fbuild in [qQ]) exit;; esac
       printf "\nUpdating the db machine  >> from commit $fbuild"
       updateDb $fbuild

      ;;
     4)
        printf "solr"
      ;;

      5)
         printf "\Updating the entire stack"
         updateFront hot
         updateRest hot
         updateDb hot
         updateSolr hot
       ;;

  esac
   removePII
fi

if [ $choice == 4 ]
  then
    addPII
    printf "\nYour infrastructure will be obliterated."
    terraform destroy
    removePII
fi

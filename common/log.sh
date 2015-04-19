#!/bin/bash
#
# marcchen, 20141125
# bash 日志模块，支持日志级别，微信输出
#
# 调用前，建议定义3个变量：
#   LOG_LEVEL   日志级别，默认 DEBUG，可取值 DEBUG INFO WARN ERROR
#   - 自动填充 LOG_SCRIPT  写日志的当前脚本名称，默认空, 可以用下面的代码获取
#   -             LOG_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/$( basename "${BASH_SOURCE[0]}" )"
#   LOG_PREFIX  自定义前缀信息，默认空
#



# local info
# LOCAL_IP=`/sbin/ifconfig | grep -A 1 ^eth1 | awk '/[[:space:]]inet / { print gensub("addr:","","g",$2) }'`

hostname=`hostname`


if [ -z "$LOG_LEVEL" ]; then
    LOG_LEVEL="DEBUG"
fi

# 非预定义日志级别时，输出
function _log_lvl_str_to_int()
{
    lvl=`echo $1 | tr '[a-z]' '[A-Z]'`
    case $lvl in
    (DEBUG)
        echo -n 10
        ;;
    (INFO)
        echo -n 20
        ;;
    (WARN)
        echo -n 30
        ;;
    (ERROR)
        echo -n 40
        ;;
    (*)
        echo -n 99
    esac
}

function show_color() {
    #Usage:4 parameters are needed!
    #      ForeColor,BackgroundClor Style and Text!
  Fg="3""$1"
  Bg="4""$2"
  SetColor="\E[""$Fg;$Bg""m"
  Style="\033[""$3""m"
  Text="$4"
  EndStyle="\033[0m"
  echo -ne "$SetColor""$Style""$Text""$EndStyle"
}

# return 1: matched, should print log
function _log_chk_lvl()
{
    lvl=$(_log_lvl_str_to_int $LOG_LEVEL)
    lvl_user=$(_log_lvl_str_to_int $1)
    if [ $lvl_user -lt $lvl ]; then
        echo -n 0
    else
        echo -n $lvl_user
    fi
}
function _log_make_msg()
{
    # 自动输出调用脚本名称，嵌套调用也会嵌套输出, 但中间脚本忽略了路径信息
    # TODO: 像普通编程语言一样打印写日志的那行代码的行号好像是不可能的
    # http://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
    n=${#BASH_SOURCE[@]}
    #echo "test ${#BASH_SOURCE[@]}"
    #echo "test ${BASH_SOURCE[@]}"
    n=$((n-1))
    last_source=${BASH_SOURCE[$n]}
    LOG_SCRIPT="$( cd "$( dirname "$last_source" )" && pwd )/$( basename "$last_source" )"
    LOG_SCRIPT=""
    #n=$((n-1))
    #
    # 通过函数调用在 BASH_SOURCE 会重复，信用嵌套显示
    #while [ $n -gt 0 ]; do
    #    src="${BASH_SOURCE[$n]}"
    #    if [ "$src" == "${BASH_SOURCE[0]}" ]; then
    #        # 有可能 0,1,2 全部都是 log.sh
    #        break;
    #    fi
    #    LOG_SCRIPT="$LOG_SCRIPT -> $src"
    #    n=$((n-1))
    #done

    s="$LOG_SCRIPT";  if [ -n "$s" ]; then s="[$s] "; fi
    p="$LOG_PREFIX";  if [ -n "$p" ]; then p="$p "; fi
    lvl="$1"; shift
    lvl=`echo $lvl | tr '[a-z]' '[A-Z]'`
    if [ $lvl != "DEBUG" ] && [ $lvl != "INFO" ] && [ $lvl != "WARN" ] && [ $lvl != "ERROR" ]; then
        lvl="UNKNOWN_LOG_LEVEL"
    fi
    echo `date +"%F %T"`" [$hostname] ${s}[$lvl] ${p}$*"
}

function _try_utf8_to_gbk()
{
    m=`echo "$*" | iconv -f utf8 -t gbk 2>/dev/null`
    if [ $? -eq 0 ]; then
        echo "$m"
    else
        echo "$*"
    fi
}

# 用法
#   参数1：日志级别
#   参数2：日志内容
function LOG()
{
    if [ $# -eq 0 ]; then
        echo
        return
    fi

    if [ $(_log_chk_lvl $1) -eq 20 ]; then
	echo $(show_color 6 10 1 "$(_log_make_msg $@)");
    else if [ $(_log_chk_lvl $1) -eq 30 ]; then
	echo $(show_color 3 10 1 "$(_log_make_msg $@)");
    else if [ $(_log_chk_lvl $1) -eq 40 ]; then
	echo $(show_color 1 10 1 "$(_log_make_msg $@)");
    else if [ $(_log_chk_lvl $1) -gt 0 ]; then
        echo $(_log_make_msg "$@")
    fi; fi; fi; fi;
}



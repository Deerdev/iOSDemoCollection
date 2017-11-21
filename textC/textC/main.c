//
//  main.c
//  textC
//
//  Created by daoquan on 2017/9/14.
//  Copyright © 2017年 deerdev. All rights reserved.
//

#include <stdio.h>

#define STR_LEN 100
int mainxxx()
{
    char str[STR_LEN];
    char target;
    int i = 0, j = 0;
    scanf("%s", str);
    i = 0;
    while(str[i] != '\0')//对字符串中的每一个字符
    {
        j = i + 1;
        while(str[i] != str[j])//搜索后面的字符，若没有相同的字符，则最终指向字符串结束标志'\0'
        {
            if(str[j] == '\0')
            {
                break;
            }
            j++;
        }
        if(str[j] == '\0')//若最终指向字符串的结束标志，则找到第一个只出现一次的字符
        {
            target = str[i];
            break;
        }
        i++;
    }
    printf("%c", target);
    return 0;
}

int main()
{
    char cStrIn[LengthMax];
    
    bool bOneTime;
    
    scanf("%s",cStrIn);
    
    int i=0;
    int j;
    while(cStrIn[i]!='\0')//遍历所有cStrIn所有字符，直到找到只出现一次时，输出该字符并返回
    {
        j=1;
        bOneTime=true;//cStrIn[i]是否只出现一次的标记位
        while(cStrIn[i+j]!='\0')//遍历cStrIn[i]后的所有字符，如果有字符与cStrIn[i]相等，则bOneTime=false，退出该循环
        {
            if(cStrIn[i+j]==cStrIn[i])
            {
                bOneTime=false;
                break;
            }
            j++;
        }
        if(bOneTime==true)
        {
            printf("%c\n",cStrIn[i]);
            return 0;
        }
        
        i++;
    }
    
    
    printf("没有出现一次的字符\n");
    return 0;
}

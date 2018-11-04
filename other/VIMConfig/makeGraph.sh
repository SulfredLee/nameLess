#!/bin/bash
dotFile=$1

dot -Tps $dotFile -o ${dotFile}.ps

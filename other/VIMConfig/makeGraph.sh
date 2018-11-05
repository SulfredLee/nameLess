#!/bin/bash
dotFile=$1

dot -Tpdf $dotFile -o ${dotFile}.pdf

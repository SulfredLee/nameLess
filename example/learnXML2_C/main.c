/*
 * adopted from http://xmlsoft.org/tutorial/apg.html
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <libxml/xmlmemory.h>
#include <libxml/parser.h>
/**
 * print_element_names:
 * @a_node: the initial xml node to consider.
 *
 * Prints the names of the all the xml elements
 * that are siblings or children of a given xml node.
 */
static void
print_element_names(xmlNodePtr a_node)
{
    xmlNodePtr cur_node = NULL;

    for (cur_node = a_node; cur_node; cur_node = cur_node->next) {
        if (cur_node->type == XML_ELEMENT_NODE) {
            printf("node type: Element, name: %s\n", cur_node->name);
        }
        if (cur_node->type == XML_TEXT_NODE) {
            printf("node type: Text, content: %s, length: %d\n", cur_node->content, strlen(cur_node->content));
        }

        print_element_names(cur_node->children);
    }
}

int
main(int argc, char **argv) {

    char         *docname;
    xmlDocPtr    doc;
    xmlNodePtr   cur;
    xmlChar      *uri;

    if (argc <= 1) {
        printf("Usage: %s docname\n", argv[0]);
        return(0);
    }

    docname = argv[1];

    doc = xmlParseFile(docname);
    cur = xmlDocGetRootElement(doc);
    print_element_names(cur);
    xmlFreeDoc(doc);
    return 1;

    cur = cur->xmlChildrenNode;
    while (cur != NULL) {
        if ((!xmlStrcmp(cur->name, (const xmlChar *)"reference"))) {
            uri = xmlGetProp(cur, "uri");
            printf("uri: %s\n", uri);
            xmlFree(uri);
        }
        cur = cur->next;
    }
    xmlFreeDoc(doc);
    return (1);
}

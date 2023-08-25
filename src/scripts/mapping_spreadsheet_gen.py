import pandas as pd
import argparse

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('infile',
                    help='Path to csv for input')
parser.add_argument('outfile', help='Path to output ')
args = parser.parse_args()

df = pd.read_csv(args.infile, sep='\t')

# remove rows with generic classification  (regional part of brain)
unwanted_uberon_mappings = ['<http://purl.obolibrary.org/obo/UBERON_0002616>']
df.rename(columns={'?sup': 'superclass_iri', '?supname': 'superclass_name',
           '?sub': 'subclass_iri', '?subname': 'subclass_name'}, inplace=True)
filtered_df = df[~df.superclass_iri.isin(unwanted_uberon_mappings)]


def gen_ols_xls_link(row):
    ont_name = 'uberon'
    link = 'https://www.ebi.ac.uk/ols/ontologies/%s/terms?iri=%s' \
           '' % (ont_name,
        row['superclass_iri'].replace('>', '').replace('<', ''))
    return'=HYPERLINK("%s","%s")' % (link, row['superclass_name'])
#urllib.parse.quote()

filtered_df.insert(0, 'superclass_name_linked',
                   value=filtered_df.apply(
                         lambda row: gen_ols_xls_link(row), axis=1))

filtered_df.drop(columns=['superclass_name'], inplace=True)

filtered_df.to_excel(args.outfile, header=True, index=False)



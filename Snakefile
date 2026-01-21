
rule all:
   input:
        "results/step10_mixture/turtle.best.treefile",
        "results/step10_mixture/turtle.2mix.treefile",
        "results/step10_mixture/turtle.4mix.treefile",
        "results/step10_mixture/turtle.6mix.treefile"

rule step2_basic:
    input:
        "data/{name}.fa"
    output:
        "results/step2_basic/{name}.fa.treefile"
    shell:
        """
        iqtree3 -s {input} -B 1000 -T AUTO --redo-tree --prefix results/step2_basic/{wildcards.name}.fa
        """


rule step3_partition:
    input:
        fa="data/{name}.fa",
        nex="data/{name}.nex"
    output:
        "results/step3_partition/{name}.nex.treefile"
    shell:
        """
        iqtree3 -s {input.fa} -p {input.nex} -B 1000 -T AUTO --prefix results/step3_partition/{wildcards.name}.nex
        """

rule step4_merge:
    input:
        fa="data/{name}.fa",
        nex="data/{name}.nex"
    output:
        iqtree="results/step4_merge/{name}.merge.iqtree",
        scheme="results/step4_merge/{name}.merge.best_scheme.nex"
    shell:
        """
        iqtree3 -s {input.fa} -p {input.nex} -B 1000 -T AUTO -m MFP+MERGE -rcluster 10 --prefix results/step4_merge/{wildcards.name}.merge
        """

rule step5_make_trees:
    input:
        tree1="results/step2_basic/{name}.fa.treefile",
        tree2="results/step3_partition/{name}.nex.treefile"
    output:
        "results/step5_test/{name}.trees"
    shell:
        """
        powershell -Command "Get-Content {input.tree1}, {input.tree2} | Set-Content {output}"
        """


rule step5_test:
    input: 
        fa="data/{name}.fa",  
        best="results/step4_merge/{name}.merge.best_scheme.nex",
        trees="results/step5_test/{name}.trees"
    output:
        "results/step5_test/{name}.test.iqtree"
    shell:
        """
        iqtree3 -s {input.fa} -p {input.best} -z {input.trees} -zb 10000 -au -n 0 --prefix results/step5_test/{wildcards.name}.test
        """
rule step6_mast:
    input:
        fa="data/{name}.fa",
        trees="results/step5_test/{name}.trees",
        scheme="results/step4_merge/{name}.merge.best_scheme.nex"
    output:
        "results/step6_mast/{name}.mix.iqtree"
    shell:
        """
        iqtree3 -s {input.fa} -p {input.scheme} -te {input.trees} -n 0 \
        --prefix results/step6_mast/{wildcards.name}.mix
        """
rule step7_wpl:
    input:
        fa="data/{name}.fa",
        scheme="results/step4_merge/{name}.merge.best_scheme.nex",
        trees="results/step5_test/{name}.trees"
    output:
        "results/step7_wpl/{name}.wpl.partlh"
    shell:
        """
        iqtree3 -s {input.fa} -p {input.scheme} -z {input.trees} -n 0 -wpl --prefix results/step7_wpl/{wildcards.name}.wpl
        """
rule step8_remove_influential_genes:
    input:
        fa="data/{name}.fa",
        nex="data/{name}.rm_influential.nex"
    output:
        "results/step8_no_influential/{name}.rm.treefile"
    shell:
        """
        iqtree3 -s {input.fa} -p {input.nex} -B 1000 -T AUTO --prefix results/step8_no_influential/{wildcards.name}.rm
        """
rule step9a_loci:
    input:
        fa="data/{name}.fa",
        nex="data/{name}.nex"
    output:
        "results/step9_cf/{name}.loci.treefile"
    shell:
        """
        iqtree3 -s {input.fa} -S {input.nex} -T 2 \
        --prefix results/step9_cf/{wildcards.name}.loci
        """
rule step9b_cf_partition:
    input:
        fa="data/{name}.fa",
        species_tree="results/step3_partition/{name}.nex.treefile",
        loci_trees="results/step9_cf/{name}.loci.treefile"
    output:
       "results/step9_cf/{name}.nex.treefile.cf.tree"
    shell:
        """
        iqtree3 -t {input.species_tree} --gcf {input.loci_trees} -s {input.fa} --scf 100 --prefix results/step9_cf/{wildcards.name}.nex.treefile
        """
rule step9c_cf_unpartitioned:
    input:
        fa="data/{name}.fa",
        species_tree="results/step2_basic/{name}.fa.treefile",
        loci_trees="results/step9_cf/{name}.loci.treefile"
    output:
        "results/step9_cf/{name}.fa.treefile.cf.tree"
    shell:
        """
        iqtree3 -t {input.species_tree} --gcf {input.loci_trees} -s {input.fa} --scf 100 --prefix results/step9_cf/{wildcards.name}.fa.treefile
        """
rule step10a_best:
    input:
        fa="data/{name}.fa"
    output:
        tree="results/step10_mixture/{name}.best.treefile",
        iqtree="results/step10_mixture/{name}.best.iqtree"
    shell:
        """
        iqtree3 -s {input.fa}  -m GTR+FO+I+R3 -B 1000 -T AUTO --prefix results/step10_mixture/{wildcards.name}.best
        """
rule step10b_mix2:
    input:
        fa="data/{name}.fa"
    output:
        tree="results/step10_mixture/{name}.2mix.treefile",
        iqtree="results/step10_mixture/{name}.2mix.iqtree"
    shell:
        """
        iqtree3 -s {input.fa} -m "MIX{{GTR+FO,GTR+FO}}+I+R3" -B 1000 -T AUTO --prefix results/step10_mixture/{wildcards.name}.2mix
        """
rule step10c_mix4:
    input:
        fa="data/{name}.fa"
    output:
        tree="results/step10_mixture/{name}.4mix.treefile",
        iqtree="results/step10_mixture/{name}.4mix.iqtree"
    shell:
        """
        iqtree3 -s {input.fa} -m "MIX{{GTR+FO,GTR+FO,GTR+FO,GTR+FO}}+I+R3" -B 1000 -T AUTO  --prefix results/step10_mixture/{wildcards.name}.4mix
        """
rule step10d_mix6:
    input:
        fa="data/{name}.fa"
    output:
        tree="results/step10_mixture/{name}.6mix.treefile",
        iqtree="results/step10_mixture/{name}.6mix.iqtree"
    shell:
        """
        iqtree3 -s {input.fa}  -m "MIX{{GTR+FO,GTR+FO,GTR+FO,GTR+FO,GTR+FO,GTR+FO}}+I+R3" -B 1000  -T AUTO  --prefix results/step10_mixture/{wildcards.name}.6mix
        """
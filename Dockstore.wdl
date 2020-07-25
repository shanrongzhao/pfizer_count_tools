version 1.0

workflow index {
  call create_indexes
}

task create_indexes {
    input {
        String output_directory
        File genome_file
        File gtf_file
        #File genome_file = "gs://fc-secure-c3bcd839-0bda-4777-af09-d609d99aaf16/Reference/GRCh38/genome.fa"
        #File gtf_file = "gs://fc-secure-c3bcd839-0bda-4777-af09-d609d99aaf16/Reference/GRCh38/genes.gtf"

        String docker = "quay.io/shanrongzhao/pfizer_count_tools"
        Int cpu = 24
        Int disk_space = 300
        Int preemptible = 2
        String zones = "us-central1-a us-central1-b us-central1-c us-central1-f us-east1-b us-east1-c us-east1-d"
        Int memory = 120
    }
    
    command {
        set -e
        export TMPDIR=/tmp

        mkdir -p  alevin-ref
        cd alevin-ref
        gffread -w "transcripts.fa" -g ${genome_file} ${gtf_file}
        t2g.py --use_version < ${gtf_file} > txp2gene.tsv
        salmon index -i salmon_index --gencode -k 31 -p ${cpu} -t transcripts.fa
        mv transcripts.fa ..
        cd ..
        tar -czf alevin.tar.gz alevin-ref
        gsutil -q -m cp alevin.tar.gz ~{output_directory}/

        mkdir -p starsolo-ref
        STAR --runThreadN ${cpu} --runMode genomeGenerate \
          --genomeDir  starsolo-ref --genomeFastaFiles ${genome_file} --sjdbGTFfile ${gtf_file}
        tar -zcf starsolo.tar.gz  starsolo-ref
        gsutil -q -m cp starsolo.tar.gz ~{output_directory}/
    }

    output {
        File starsolo_tar_index = '~{output_directory}/starsolo.tar.gz'
        File alevin_tar_index = '~{output_directory}/alevin.tar.gz'
    }

    runtime {
        docker: "~{docker}"
        zones: zones
        memory: "~{memory}G"
        disks: "local-disk ~{disk_space} HDD"
        cpu: "~{cpu}"
        preemptible: "~{preemptible}"
    }
}


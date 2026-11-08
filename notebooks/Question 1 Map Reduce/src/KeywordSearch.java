
import java.util.Scanner;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class KeywordSearch {

    public static void main(String[] args) throws Exception {

        if (args.length != 2) {
            System.out.println("Usage: KeywordSearch <input folder> <output folder>");
            System.exit(1);
        }

        Scanner input = new Scanner(System.in);

        System.out.print("Enter keyword to search for: ");
        String keyword = input.nextLine().trim();

        if (keyword.isEmpty()) {
            System.out.println("Please enter a keyword.");
            input.close();
            System.exit(1);
        }

        Configuration configuration = new Configuration();

configuration.set("search.keyword", keyword);
configuration.set("mapreduce.framework.name", "local");
configuration.set("fs.defaultFS", "file:///");
configuration.set("hadoop.tmp.dir", "C:/hadoopsetup/tmp");
configuration.set("mapreduce.jobtracker.staging.root.dir",
        "C:/hadoopsetup/tmp/staging");

        Job job = Job.getInstance(configuration, "Keyword Search");

        job.setJarByClass(KeywordSearch.class);

        job.setMapperClass(KeywordMapper.class);
        job.setReducerClass(KeywordReducer.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        input.close();

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}

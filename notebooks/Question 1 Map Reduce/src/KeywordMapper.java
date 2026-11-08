
import java.io.IOException;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;

public class KeywordMapper extends Mapper<LongWritable, Text, Text, Text> {

    private String keyword;
    private String documentName;
    private int lineNumber = 0;

    @Override
    protected void setup(Context context) {
        keyword = context.getConfiguration().get("search.keyword").toLowerCase();
        documentName = ((FileSplit) context.getInputSplit()).getPath().getName();
    }

    @Override
    protected void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {

        lineNumber++;

        String line = value.toString();
        String lowerLine = line.toLowerCase();

        int position = 0;

        while ((position = lowerLine.indexOf(keyword, position)) != -1) {
            String location = documentName + ", line " + lineNumber
                    + ", character position " + (position + 1);

            context.write(new Text(keyword), new Text(location));
            position++;
        }
    }
}

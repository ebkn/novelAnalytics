import org.atilika.kuromoji.Token;
import org.atilika.kuromoji.Tokenizer;
import java.util.List;

final int targetNum = 5;
final int[][] pairs = {
  {0,1}, {0,2}, {0,3}, {0,4}, {1,2}, {1,3}, {1,4}, {2,3}, {2,4}, {3,4}
};

void setup() {
  HashMap<String, int[]> allBagOfWords = new HashMap<String, int[]>();

  for (int n=0; n<targetNum; n++) {
    // load strings
    String filename = "ch" + (n+1) + ".txt";
    String targetString = loadStrings(filename)[0];
    println(filename + " loaded.");

    // initialization
    HashMap<String, Integer> bagOfWords = new HashMap<String, Integer>();
    Tokenizer tokenizer = Tokenizer.builder().build();
    List<Token> tokenList = tokenizer.tokenize(targetString);

    for (Token token : tokenList) {
      if (isInvalid(token)) continue;

      int count = (bagOfWords.get(token.getSurfaceForm()) != null) ? bagOfWords.get(token.getSurfaceForm()) + 1 : 1;
      bagOfWords.put(token.getSurfaceForm(), count);
    }

    // set bagOfWords to allBagOfWords
    for (String keyword : bagOfWords.keySet()) {
      int keywordCount = bagOfWords.get(keyword);
      int[] tmpArray = new int[targetNum];
      if (allBagOfWords.get(keyword) == null) {
        for (int i=0; i<tmpArray.length; i++) {
          tmpArray[i] = i == n ? keywordCount : 0;
        }
        allBagOfWords.put(keyword, tmpArray);
      } else {
        tmpArray = allBagOfWords.get(keyword);
        tmpArray[n] = keywordCount;
        allBagOfWords.put(keyword, tmpArray);
      }
    }

    // calcurate tf-idf
    println("-- tf-ifdf --");
    int listSize = tokenList.size();
    for (String keyword : bagOfWords.keySet()) {
      int keywordCount = bagOfWords.get(keyword);
      float tf = (float)keywordCount / listSize;
      float idf = log(listSize / keywordCount);
      float tfidf = tf * idf;
      if (tfidf > 0.02) {
        println(keyword + " " + tfidf);
      }
    }
  }

  // calc cosine simirality
  println("-- cosine simirality --");
  for (int i=0; i<pairs.length; i++) {
    float value =0;
    float innerProduct = 0;
    float absoluteValue1 = 0;
    float absoluteValue2 = 0;
    for (String keyword : allBagOfWords.keySet()) {
      int val1 = allBagOfWords.get(keyword)[pairs[i][0]];
      int val2 = allBagOfWords.get(keyword)[pairs[i][1]];
      innerProduct += val1 * val2;
      absoluteValue1 += val1 * val1;
      absoluteValue2 += val2 * val2;
    }
    value = innerProduct / (sqrt(absoluteValue1) * sqrt(absoluteValue2));
    println(pairs[i][0] + " " + pairs[i][1] + " : " + value);
  }

  exit();
}

boolean isInvalid(Token token) {
  if (!token.getAllFeaturesArray()[0].equals("名詞") && token.getAllFeaturesArray()[0].equals("形容詞")) {
    return true;
  }

  String word = token.getSurfaceForm();
  ArrayList<String> invalidWords = new ArrayList<String>();
  invalidWords.add("、");
  invalidWords.add("。");
  invalidWords.add("（");
  invalidWords.add("）");
  invalidWords.add("「");
  invalidWords.add("」");
  invalidWords.add("・");
  invalidWords.add("一");
  invalidWords.add("二");
  invalidWords.add("三");
  invalidWords.add("十");
  invalidWords.add("これ");
  invalidWords.add("それ");
  invalidWords.add("あれ");
  invalidWords.add("いる");
  invalidWords.add("ある");
  invalidWords.add("する");
  invalidWords.add("れる");
  invalidWords.add("この");
  invalidWords.add("ない");
  invalidWords.add("その");
  invalidWords.add("でし");
  invalidWords.add("です");
  return invalidWords.contains(word) || word.length() == 1;
}

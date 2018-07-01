import org.atilika.kuromoji.Token;
import org.atilika.kuromoji.Tokenizer;
import java.util.List;

int targetNum = 5;
String targetString;
HashMap<String, int[]> allBagOfWords;
HashMap<String, Integer> bagOfWords;
Tokenizer tokenizer;
List<Token> tokenList;
boolean printFeaturesEnabled = false;

void setup() {
  allBagOfWords = new HashMap<String, int[]>();
  for (int n=0; n<targetNum; n++) {
    // load strings
    String filename = "ch" + (n+1) + ".txt";
    targetString = loadStrings(filename)[0];
    println("-----------------");
    println(filename + " loaded.");

    // initialization
    bagOfWords = new HashMap<String, Integer>();
    tokenizer = Tokenizer.builder().build();
    tokenList = tokenizer.tokenize(targetString);

    for (Token token : tokenList) {
      if (!token.getAllFeaturesArray()[0].equals("名詞") && token.getAllFeaturesArray()[0].equals("形容詞")) continue;
      if (isInvalid(token.getSurfaceForm())) continue;

      if (bagOfWords.get(token.getSurfaceForm()) == null) {
        bagOfWords.put(token.getSurfaceForm(), 1);
      } else {
        int count = bagOfWords.get(token.getSurfaceForm());
        bagOfWords.put(token.getSurfaceForm(), count + 1);
      }

      // print features of words
      if (printFeaturesEnabled) printFeatures(token);
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
  int[][] pairs = {
    {0,1}, {0,2}, {0,3}, {0,4}, {1,2}, {1,3}, {1,4}, {2,3}, {2,4}, {3,4}
  };
  float values[] = new float[pairs.length];
  for (int i=0; i<pairs.length; i++) {
    values[i] =0;
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
    absoluteValue1 = sqrt(absoluteValue1);
    absoluteValue2 = sqrt(absoluteValue2);
    println(innerProduct + " " + absoluteValue1 + " " + absoluteValue2);
    values[i] = innerProduct / (absoluteValue1 * absoluteValue2);
  }
  for (int i=0; i<pairs.length; i++) {
    println(pairs[i][0] + " " + pairs[i][1] + " : " + values[i]);
  }

  exit();
}

boolean isInvalid(String word) {
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

void printFeatures(Token token) {
  String[] features = token.getAllFeaturesArray();
  println("##########################################################");
  println("表記　　：" + token.getSurfaceForm());
  println("品詞　　：" + token.getPartOfSpeech());
  println("原型　　：" + token.getBaseForm());
  println("読み　　：" + token.getReading());
  println("既知語　：" + token.isKnown());
  println("未知語　：" + token.isUnknown());
  println("ユーザ辞書？：" + token.isUser());
  println("すべてのfeature：" + token.getAllFeatures());
  println("fearures[0] 品詞１　：" + features[0] );
  println("fearures[1] 品詞２　：" + features[1]);
  println("fearures[2] 品詞３　：" + features[2]);
  println("fearures[3] 品詞４　：" + features[3]);
  println("fearures[4] 活用形１：" + features[4]);
  println("fearures[5] 活用形２：" + features[5]);
  println("fearures[6] 原型　　：" + features[6]);
  if (features.length == 9) {
    println("fearures[7] 読み　　：" + features[7]);
    println("fearures[8] 発音　　：" + features[8]);
  }
}

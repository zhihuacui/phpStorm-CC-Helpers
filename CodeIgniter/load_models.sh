#!/usr/bin/php
<?php
/**
 * Created by PhpStorm.
 * User: zhome
 * Date: 16/9/1
 * Time: 下午12:43
 */
$f = new File($argv[1]);
$w = new Write();
$w->writeConfig(File::CONFIGFILE, $f->names);




class File
{
    public $names = array();
    public static $JUMP_DIR = array('.', '..', 'tools', 'fonts', 'include', 'examples', 'config');
    const WEBROOT = '~/Webroot/';
    const CONFIGFILE = '/Users/zhome/Webroot/phpStorm-CC-Helpers/CodeIgniter/my_models.php';
    public function __construct($dir)
    {
        $this->names = $this->getNames($dir);
    }

    public function getNames($argv)
    {
        $argv = is_dir($argv) ? $argv : self::WEBROOT . $argv;
        $dirs = array();
        $files = array();
        $dirs[] = exec('find ' . $argv . ' -type d  -regex ".*application/libraries$"');
        $dirs[] = exec('find ' . $argv . ' -type d  -regex ".*admin-model/models$"');
        foreach (array_filter($dirs) as $dir) {
            $files = array_merge($files, $this->getFileNames($dir));
        }
        return $files;
    }

    public function getFileNames($dir, $item = null)
    {
        $dir = isset($item) ? realpath($dir) . '/' . $item : realpath($dir);
        if (is_dir($dir) && !in_array($item, self::$JUMP_DIR)) {
            //$items = explode(' ', exec('ls '. $dir . '|xargs'));
            $items = scandir($dir);
            $names = array();
            foreach ($items as $item) {
                $res = $this->getFileNames($dir, $item);
                $names = array_merge($names, $res);
            }
            return $names;
        } elseif (!in_array($item, self::$JUMP_DIR)) {
            $fileArr = explode('.', $item);
            $ext = array_pop($fileArr);
            if ($ext == 'php') {
                return array(join('.', $fileArr));
            }
            return array();
        } else {
            return array();
        }
    }
}

class Write {

    public function writeConfig($file, $data) {
        $fileData = $this->getFileData($file);
        $res = $this->formatFileData($fileData);
        $pos = $res['pos'];
        $data = array_values($this->formatData($data));
        $data = array_merge($data, array_values($res['data']));
        $data = array_unique($data);
        array_splice($fileData, $pos, 0, $data);
        $newFile = join("\n", $fileData);
        file_put_contents($file, $newFile);
    }
    private function getFileData($file){
        if (!file_exists($file)) {
            throw new Exception("File not found: $file");
        }
        if (!is_readable($file) || !is_writeable($file)) {
            throw new Exception("Unable to read/write to file: $file");
        }
        return array_filter(file($file), function($a) {
            return strlen($a) > 1;
        });
    }

    private function formatData($data) {
        $return = array();
        foreach ($data as $line) {
            if (!strpos($line, 'model')) {
                $line = strtolower($line);
            }
            $return[] = '* @property ' . $line . ' $' . $line;
        }
        return $return;
    }
    private function formatFileData(&$data) {
        var_dump($data);
        $pos = 14;
        $i = 1;
        $config = array();
        foreach ($data as $lineNo => $line) {
            $i++;
            if (strpos($line, 'property')) {
                unset($data[$lineNo]);
                $config[] = trim($line);
            }
            if (strpos($line, 'example')) {
                $pos = $i;
            }
        }
        return array('pos' => $pos, 'data' => $config);
    }

}
?>

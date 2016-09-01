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

print_r($f);



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
        $pos = $this->formatFileData($fileData);
        $data = $this->formatData($data);
        $newFile = array_splice($fileData, $pos+1, null, $data);
        $newFile = join("\n", $newFile);
        file_put_contents($file, $newFile);
    }
    private function getFileData($file){
        if (!file_exists($file)) {
            throw new Exception("File not found: $file");
        }
        if (!is_readable($file) || !is_writeable($file)) {
            throw new Exception("Unable to read/write to file: $file");
        }
        return file_get_contents($file);
    }

    private function formatData($data) {
        $return = array();
        foreach ($data as $line) {
            $return[] = '* @property ' . $line . '$' . $line;
        }
        return $return;
    }
    private function formatFileData(&$data) {
        $fileArr =  explode("\n", $data);
        $pos = 14;
        foreach ($fileArr as $lineNo => $line) {
            if (strpos($line, 'property')) {
                unset($fileArr[$lineNo]);
            }
            if (strpos($line, 'example')) {
                $pos = $lineNo;
            }
        }
        return $pos;
    }

}
?>

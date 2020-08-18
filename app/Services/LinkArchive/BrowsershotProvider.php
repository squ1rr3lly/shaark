<?php

namespace App\Services\LinkArchive;

use Spatie\Browsershot\Browsershot;

class BrowsershotProvider extends BaseProvider
{
    public function makeArchive(): ?string
    {
        $name = md5($this->url) . '.pdf';
        $filename = sprintf('app/archives/%s', $name);
        $windowWidth = app('shaark')->getArchivePdfWidth();
        $windowHeight = app('shaark')->getArchivePdfHeight();
        $nodeBin = app('shaark')->getNodeBin();

        try {
            Browsershot::url($this->url)
                ->windowSize($windowWidth, $windowHeight)
                ->margins(0,0,0,0)
                ->setNodeBinary($nodeBin)
                ->showBackground()
                ->addChromiumArguments([
                    'disable-dev-shm-usage'
                ]);
                ->noSandbox()
                ->ignoreHttpsErrors()
                ->dismissDialogs()
                ->waitUntilNetworkIdle()
                ->emulateMedia('screen')
                ->savePdf($filename);
        } catch (\Exception $e) {
            throw new \RuntimeException("Unable to create link pdf archive", 0, $e);
        }

        return $name;
    }

    public function isEnabled(): bool
    {
        return app('shaark')->getLinkArchivePdf() === true;
    }

    public function canArchive(): bool
    {
        return true;
    }
}

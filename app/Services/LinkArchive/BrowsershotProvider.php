<?php

namespace App\Services\LinkArchive;

use Spatie\Browsershot\Browsershot;

class BroswershotProvider extends BaseProvider
{
    public function makeArchive(): ?string
    {
        $name = md5($this->url) . '.pdf';
        $filename = sprintf('app/archives/%s', $name);

        try {
            Browsershot::url($this->url)
                ->paperSize(app('shaark')->getArchivedPdfWidth(), app('shaark')->getArchivedPdfHeight())
                ->margins(0,0,0,0)
                ->showBackground()
                ->noSandbox()
                ->ignoreHttpsErrors()
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
